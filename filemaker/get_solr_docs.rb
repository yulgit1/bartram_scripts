require 'httparty'

#scans
ids_file = "scan_ids.txt"
ids_array = Array.new
File.open(ids_file, "r") do |f|
  f.each_line do |line|
    ids_array.push line
  end
end

ids_array.each_with_index do |id,i|
  #break if i > 1
  url = "http://localhost:8983/solr/bertram2/select?fq=id%3A#{id}&fl=*&wt=json&indent=true"
  response = HTTParty.get(url)
  doc = response.parsed_response["response"]["docs"][0]
  file = "scans/" + doc["id"] + ".txt"
  IO.write("#{file}", doc)
end

#objects
ids_file = "object_ids.txt"
ids_array = Array.new
File.open(ids_file, "r") do |f|
  f.each_line do |line|
    ids_array.push line
  end
end

ids_array.each_with_index do |id,i|
  #break if i > 1
  url = "http://localhost:8983/solr/bertram2/select?fq=id%3A#{id}&fl=*&wt=json&indent=true"
  response = HTTParty.get(url)
  doc = response.parsed_response["response"]["docs"][0]
  file = "objects/" + doc["id"] + ".txt"
  IO.write("#{file}", doc)
end

#filename = "scan-0001.txt"
#file = File.read filename
#filehash = eval(file)
#filehash["recto_s"]
#YAML.load(%Q(---\n"#{s}"\n))
