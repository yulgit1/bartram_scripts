require 'roo'
require 'json'
require 'httparty'
require 'writeexcel'

workbook = WriteExcel.new('./scansfp.xls')
worksheet = workbook.add_worksheet

worksheet.write(0, 0, "scanID")
worksheet.write(0, 1, "title")
worksheet.write(0, 2, "subject")
worksheet.write(0, 3, "author")
worksheet.write(0, 4, "partof")
worksheet.write(0, 5, "location")
worksheet.write(0, 6, "contents")
worksheet.write(0, 7, "recto")
worksheet.write(0, 8, "verso")
worksheet.write(0, 9, "photo")
worksheet.write(0, 10, "institutional_stamp")
worksheet.write(0, 11, "format")
worksheet.write(0, 12, "docx_path")
worksheet.write(0, 13, "pdf_path")

dir = "/Users/erjhome/RubymineProjects/Amy_Natural_History/filemaker/scans"
Dir.chdir(dir)
Dir.glob("*").each_with_index do |f,i|
  ii = i + 1
  #break if i > 4
  fullpath = "#{dir}/#{f}"
  file = File.read fullpath
  filehash = eval(file)

  num = f.gsub("scan-","").gsub(".txt","").strip
  docx = Dir["/Users/erjhome/RubymineProjects/Amy_Natural_History/Meyers Natural History_Binders/**/#{num}*.docx"]
  pdf = Dir["/Users/erjhome/RubymineProjects/Amy_Natural_History/Meyers Natural History_Binders/**/#{num}*.pdf"]
  basedir = "/Users/ermadmix/scp/Amy_Natural_History/Meyers Natural History_Binders"
  docx2 = basedir + docx[0].gsub("/Users/erjhome/RubymineProjects/Amy_Natural_History/Meyers Natural History_Binders","")
  pdf2 = basedir + pdf[0].gsub("/Users/erjhome/RubymineProjects/Amy_Natural_History/Meyers Natural History_Binders","")
  #puts docx2
  #puts pdf2
  #s = filehash["opensearch_display"]
  #puts "---"
  #puts f
  #puts s
  #YAML.load(%Q(---\n"#{s}"\n))
  worksheet.write(ii, 0, filehash["id"])
  worksheet.write(ii, 1, filehash["title_display"])
  worksheet.write(ii, 2, filehash["subject_topic_s"])
  worksheet.write(ii, 3, filehash["author_t"].join(",")) unless filehash["author_t"].nil?
  worksheet.write(ii, 4, filehash["part_of_s"])
  worksheet.write(ii, 5, filehash["location_s"])
  worksheet.write(ii, 6, filehash["contents_s"])
  worksheet.write(ii, 7, filehash["recto_s"])
  worksheet.write(ii, 8, filehash["verso_s"])
  worksheet.write(ii, 9, filehash["photo_s"])
  worksheet.write(ii, 10, filehash["institutional_stamp_s"])
  worksheet.write(ii, 11, filehash["format"])
  worksheet.write(ii, 12, docx2)
  worksheet.write(ii, 13, pdf2)
end

workbook.close
