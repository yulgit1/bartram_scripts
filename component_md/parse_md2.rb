require 'json'
require 'rsolr'
require 'uri'
require 'fileutils'

#helper method
def parse_key_for_subject(k)
  #get subject from filename in notebook_markdown directory
  if k.split("_")[0].gsub("s","").length == 1
    k = k.gsub("s","s0")
  end
  #puts "k:"+k
  f = k.split("_").slice(0..1).join("_").gsub("s","entry").gsub("b","book")
  d = "/Users/erjhome/RubymineProjects/Amy_Natural_History/notebook_markdown"
  fd = d+'/'+f+'*.md'
  #puts "fd:" + fd
  ff = Dir.glob(fd).each { |md_file| md_file }
  bn = File.basename(ff[0],".md")
  sub = bn.split('-')[1]
  sub = "" if sub.nil?
  return sub
end


#Still need notion of object that will get indexed with imagescan,metadata,and these blocks
#onefile = "/Users/erjhome/RubymineProjects/Amy_Natural_History/erj/notebook_markdown/entry00_book1_BIBLIO.md"
#onefile = "/Users/erjhome/RubymineProjects/Amy_Natural_History/component_md/sample1/s12_b4_tagged.md"

#tagged_notebooks = "/Users/erjhome/RubymineProjects/Amy_Natural_History/component_md/sample1"
tagged_notebooks = "/Users/erjhome/RubymineProjects/Amy_Natural_History/component_md/tagged_md1/Notebook 8"
solr_notebooks = "/Users/erjhome/RubymineProjects/Amy_Natural_History/component_md/tagged_md1/Notebook 8/solrdocs"
solr_scans = "/Users/erjhome/RubymineProjects/Amy_Natural_History/component_md/solrscans"

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

Dir.chdir("/Users/erjhome/RubymineProjects/Amy_Natural_History/component_md")

File.open('blocks.json',"w+") do |f|
  f << blocks.to_json
end
fblocks = Hash.new
File.open('blocks.json') do |f|
  fblocks = JSON.parse(f.read)
end

solr_url = 'http://127.0.0.1:8983/solr/bertram1'
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
  subject = parse_key_for_subject(k)
  label = "Notebook #{book}, Entry #{entry}, Object #{object}"
  scan = ""
  scan_file = ""
  scan = k.split("_")[3].gsub("sc","") if (k.split("_").length == 4)
  scan_str = "scan-" + "%04d" % scan.to_i if (k.split("_").length == 4)
  scan_file = "metadata-"+ "%04d" % scan.to_i if (k.split("_").length == 4)

  doc = Hash.new
  doc[:id] = id
  doc[:entry_s] = entry
  doc[:book_s] = book
  doc[:object_s] = object
  doc[:subject_s] = subject if subject.empty? == false
  doc[:label_s] = label
  doc[:location_s] = "Yale Center for British Art"
  doc[:author_s] = "Meyers, Amy"
  doc[:scan_s] = scan_str if scan.empty? == false
  doc[:entries_t] = v
  doc[:timestamp] = Time.now.utc

  scan_hash = Hash.new
  if scan_file.length > 0
    File.open(solr_scans+"/"+scan_file+".json") do |f|
      scan_hash = eval(f.read)
    end
    doc[:has_scan_s] = "scan"
    doc = doc.merge(scan_hash)
  else
    doc[:has_scan_s] = "no scan"
  end


  solr.add doc
  file = File.open("#{solr_notebooks}/#{id}.json", 'w')
  file.write(doc)
  file.close
end
solr.commit
