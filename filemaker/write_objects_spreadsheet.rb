require 'roo'
require 'json'
require 'httparty'
require 'writeexcel'

workbook = WriteExcel.new('./objects2.xls')
worksheet = workbook.add_worksheet

worksheet.write(0, 0, "objectID")
worksheet.write(0, 1, "scanID")
worksheet.write(0, 2, "subject")
worksheet.write(0, 3, "label")
worksheet.write(0, 4, "location")
worksheet.write(0, 5, "entries")
worksheet.write(0, 6, "has_scan")
worksheet.write(0, 7, "gnrd")
worksheet.write(0, 8, "notebook")

dir = "/Users/erjhome/RubymineProjects/Amy_Natural_History/filemaker/objects"
Dir.chdir(dir)
Dir.glob("*").each_with_index do |f,i|
  ii = i + 1
  #break if i > 4
  fullpath = "#{dir}/#{f}"
  file = File.read fullpath
  filehash = eval(file)
  #s = filehash["opensearch_display"]
  #puts "---"
  #puts f
  #puts s
  #YAML.load(%Q(---\n"#{s}"\n))
  #puts filehash.inspect
  begin
  worksheet.write(ii, 0, filehash["id"])
  worksheet.write(ii, 1, filehash["scan_sm"].join(",")) unless filehash["scan_sm"].nil?
  worksheet.write(ii, 2, filehash["subject_s"])
  worksheet.write(ii, 3, filehash["label_s"])
  worksheet.write(ii, 4, filehash["location_s"])
  worksheet.write(ii, 5, filehash["entries_t"].join("\n")) unless filehash["entries_t"].nil?
  has_scan = "yes" if filehash["has_scan_s"] == "scan"
  has_scan = "no" if filehash["has_scan_s"] == "no scan"
  worksheet.write(ii, 6, has_scan)
  worksheet.write(ii, 7, filehash["gnrd_sm"].join(",")) unless filehash["gnrd_sm"].nil?
  notebook = "Notebook #{filehash["book_s"]}, Entry #{filehash["entry_s"]}"
  worksheet.write(ii, 8, notebook)
rescue Exception => e
  puts "-----"
  puts "ERROR: #{e.message}"
  puts filehash.inspect
  next
end
end

workbook.close
