require 'roo'
require 'json'
require 'httparty'
require 'writeexcel'

workbook = WriteExcel.new('./notebooks.xls')
worksheet = workbook.add_worksheet

worksheet.write(0, 0, "filename")
worksheet.write(0, 1, "fullname")
worksheet.write(0, 2, "book")
worksheet.write(0, 3, "entry")
worksheet.write(0, 4, "subject")

dir = "/Users/erjhome/RubymineProjects/Amy_Natural_History/Bartram Files Updated"
Dir.chdir(dir)
Dir.glob("**/*.docx").each_with_index do |f,i|
  ii = i + 1
  puts f

  filename = f.split("/")[1].gsub("section","entry")
  notebook_num = f.split("/")[0].gsub("Notebook","")
  entry_num = f.split("/")[1].split("_")[0].gsub("section","")
  fullname = "Notebook #{notebook_num}, Entry #{entry_num}"
  subject = f.split("_")[2].gsub(".docx","")
  begin
  worksheet.write(ii, 0, filename)
  worksheet.write(ii, 1, fullname)
  worksheet.write(ii, 2, notebook_num)
  worksheet.write(ii, 3, entry_num)
  worksheet.write(ii, 4, subject)
rescue Exception => e
  puts "-----"
  puts "ERROR: #{e.message}"
  puts filehash.inspect
  next
end
end

workbook.close
