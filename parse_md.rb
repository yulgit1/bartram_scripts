require 'json'

#Still need notion of object that will get indexed with imagescan,metadata,and these blocks
file = "/Users/erjhome/RubymineProjects/Amy_Natural_History/erj/notebook_markdown/entry00_book1_BIBLIO.md"

block = false
id = ""
lines = ""
blocks = Hash.new
File.readlines(file).each do |line|
  if line.start_with?("[](start")
    block = true
    id = line
    lines = ""
    next
  end
  if line.start_with?("[](end")
    block = false
    key = id.split(" ")[1].gsub(")","")
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

File.open('blocks.json',"w+") do |f|
  f << blocks.to_json
end
fblocks = Hash.new
File.open('blocks.json') do |f|
  fblocks = JSON.parse(f.read)
end

fblocks.each do |k,v|
  puts "----"
  puts k
  v.each_with_index do |v,i|
    puts "#{i}:#{v}"
  end
end
