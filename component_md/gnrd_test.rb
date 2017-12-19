require 'open3'
require 'json'
require 'httparty'

#f = "/Users/erjhome/RubymineProjects/Amy_Natural_History/Meyers Natural History_Notebooks/Book 1/entry00_book1_BIBLIO.docx"
f = "/Users/erjhome/RubymineProjects/Amy_Natural_History/component_md/tagged_md1/Notebook 1/s00_b1_tagged.md"
s = "http://gnrd.globalnames.org/name_finder.json"

cmd = 'curl -D - -F "file=@'+f+'" '+s
#puts cmd
l = ""
Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
  l = stdout.readlines[8].gsub("Location: ","").strip
  #puts "stderr is:" + stderr.read
end

puts l

a = Array.new
response = HTTParty.get(l)
json = JSON.parse(response.body)
json["names"].each do |name|
  a.push(name["scientificName"])
end

puts a.inspect