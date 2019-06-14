require 'roo'
require 'json'
require 'httparty'
require 'writeexcel'

workbook = WriteExcel.new('./scansu1.xls')
worksheet = workbook.add_worksheet

worksheet.write(0, 0, "scanID")
worksheet.write(0, 1, "csn_t")
worksheet.write(0, 2, "cvn_t")
worksheet.write(0, 3, "hsn_t")
worksheet.write(0, 4, "hvn_t")
worksheet.write(0, 5, "notes_t")
worksheet.write(0, 6, "sources_t")

dir = "/Users/ermadmix/Documents/RubymineProjects/Amy_Natural_History/filemaker/updated_scans1"
Dir.chdir(dir)
Dir.glob("*").each_with_index do |f,i|
  ii = i + 1
  #break if i > 4
  fullpath = "#{dir}/#{f}"
  file = File.read fullpath
  filehash = eval(file)


  worksheet.write(ii, 0, filehash["id"])
  worksheet.write(ii, 1, filehash["csn_t"])
  worksheet.write(ii, 2, filehash["cvn_t"])
  worksheet.write(ii, 3, filehash["hsn_t"])
  worksheet.write(ii, 4, filehash["hvn_t"])
  worksheet.write(ii, 5, filehash["notes_t"])
  worksheet.write(ii, 6, filehash["sources_t"])
  puts "another 50..." if i%50 == 0
end

workbook.close
