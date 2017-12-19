require 'open3'
require 'json'
require 'httparty'


s = "http://gnrd.globalnames.org/name_finder.json"
#with file
#f = "/Users/erjhome/RubymineProjects/Amy_Natural_History/Meyers Natural History_Notebooks/Book 1/entry00_book1_BIBLIO.docx"
#f = "/Users/erjhome/RubymineProjects/Amy_Natural_History/component_md/tagged_md1/Notebook 1/s00_b1_tagged.md"
#cmd = 'curl -D - -F "file=@'+f+'" '+s

t = "\r\n> Albin, Eleazar Descs. & Drawings of English & Foreign Spiders, 1732\r\n> (SI. 4001) drawings of amphibians & reptiles (Add 5272)\r\n"

f = "object_tmp.txt"
open(f, 'w') { |f|
  f.puts t
}
cmd = 'curl -D - -F "file=@'+f+'" '+s


#puts cmd
l = ""
Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
  #puts "stderr is:" + stderr.read
  #puts "stdout is:" + stdout.read
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