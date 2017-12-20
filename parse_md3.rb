require 'json'
require 'rsolr'
require 'uri'
require 'fileutils'
require 'open3'
require 'httparty'

#configuration notes

# 1) change tagged_notebooks and solr_notebooks directory to reflect each of Notebooks 1-9, and run script for each

#input
tagged_notebooks = "/Users/erjhome/RubymineProjects/Amy_Natural_History/Bartram Files Updated/Notebook1/Notebook1 mds/Tagged Files"
#output
solr_notebooks = "/Users/erjhome/RubymineProjects/Amy_Natural_History/Bartram Files Updated/Notebook1/Notebook1 mds/Tagged Files/solrdocs"
solr_scans = "/Users/erjhome/RubymineProjects/Amy_Natural_History/component_md/solrscans"

def parse_key_for_subject(k,d)
  #get subject from filename in notebook_markdown director

  f = k.split("_").slice(0..1).join("_").gsub("s","section").gsub("b","book")
  #d = "/Users/erjhome/RubymineProjects/Amy_Natural_History/notebook_markdown"
  #d = tagged_notebooks
  fd = d+'/'+f+'*.md'
  #puts "fd:" + fd
  ff = Dir.glob(fd).each { |md_file| md_file }
  return "" if ff.empty?
  bn = File.basename(ff[0],".md")
  sub = bn.split('-')[1]
  if sub.nil?
    puts "sub is nil"
    return ""
  else
    puts "sub:" + sub
    sub2 = sub.gsub("_tagged","")
    puts "sub2:" + sub2
    return sub2
  end
end

FileUtils::mkdir_p solr_notebooks

blocks = Hash.new
Dir.chdir(tagged_notebooks)
Dir.glob('*.md').each { |file|

  block = false
  id = ""
  lines = ""

  File.readlines(file).each do |line|
    #puts line
    if line.start_with?("[ ](start")
      block = true
      id = line
      lines = ""
      next
    end
    if line.start_with?("[ ](end")
      block = false
      #key = id.split(" ")[1].gsub(")","")
      key = /['].*[']/.match(id)[0].gsub("'","")
      if blocks[key]
        array = blocks[key]
      else
        array = []
        end
      blocks[key] = array.push(lines)
    end
    if block == true
      lines = lines + line
    end
  end

}

#Dir.chdir("/Users/erjhome/RubymineProjects/Amy_Natural_History/component_md")
Dir.chdir(tagged_notebooks)

File.open('blocks.json',"w+") do |f|
  f << blocks.to_json
end
fblocks = Hash.new
File.open('blocks.json') do |f|
  fblocks = JSON.parse(f.read)
end


solr_url = 'http://127.0.0.1:8983/solr/bertram2'
solr = RSolr.connect :url => solr_url
fblocks.each do |k,v|
  puts "----"
  puts k
  #v.each_with_index do |v,i|
  #  puts "#{i}:#{v}"
  #end

  id = k.split("_").slice(0..2).join("_")
  entry = k.split("_")[0].gsub("s","")
  book = k.split("_")[1].gsub("b","")
  object = k.split("_")[2].gsub("o","")
  subject = parse_key_for_subject(k,tagged_notebooks)
  label = "Notebook #{book}, Entry #{entry}, Object #{object}"
  #scan = ""
  #scan_file = ""
  scan_arr = Array.new
  scan_arr = k.split("_")[3].gsub("sc","").split("-") if (k.split("_").length == 4)
  scan_arr_str = scan_arr.map { |s| "scan-" + "%04d" % s.to_i }
  scan_arr_file = scan_arr.map { |s| "metadata-" + "%04d" % s.to_i }


  doc = Hash.new
  doc[:id] = id
  doc[:entry_s] = entry
  doc[:book_s] = book
  doc[:object_s] = object
  doc[:subject_s] = subject if subject.empty? == false
  doc[:label_s] = label
  doc[:location_s] = "Yale Center for British Art"
  doc[:author_s] = "Meyers, Amy"
  doc[:scan_sm] = scan_arr_str if scan_arr_str.empty? == false
  doc[:entries_t] = v
  doc[:timestamp] = Time.now.utc

  a = Array.new
  if scan_arr_file.length > 0
    doc[:has_scan_s] = "scan"
    scan_arr_file.each { |s|
      File.open(solr_scans+"/"+s+".json") do |f|
        a.push(eval(f.read))
      end
    }
  else
    doc[:has_scan_s] = "no scan"
  end
  h = Hash.new
  a.each { |x|
    x.each { |k,v|
      if k.to_s.split("_").last == "s"
        s = k.to_s+"m"
      elsif k.to_s.split("_").last == "t"
        s = k.to_s
      end
      key = s.to_sym
      h[key] ||= []
      h[key] << v
    }
  }
  doc = doc.merge(h)

  #gnrd - Global Names Recognition and Discovery
  #http://gnrd.globalnames.org/api
  s = "http://gnrd.globalnames.org/name_finder.json"
  f = "object_tmp.txt"
  open(f, 'w') { |f|
    f.puts v
  }
  cmd = 'curl -D - -F "file=@'+f+'" '+s
  l = ""
  Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
    l = stdout.readlines[8].gsub("Location: ","").strip
  end
  a = Array.new
  response = HTTParty.get(l)
  json = JSON.parse(response.body)
  json["names"].each do |name|
    a.push(name["scientificName"])
  end

  puts "gnrd:" + a.inspect
  doc[:gnrd_sm] = a if a.size > 0
  doc[:format] = 'object'
  doc[:object_type_s] = "object" #vs "scan"

  solr.add doc
  file = File.open("#{solr_notebooks}/#{id}.json", 'w')
  file.write(doc)
  file.close
end
solr.commit
