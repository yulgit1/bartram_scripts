require 'fileutils'

#usage notes
#this is used specifically to stage notebooks 7-8 for parse_key_for_subject lookup
#it first changes the naming convention from "section" to "entry"
#it then converts the docx to md

root_directory = '/Users/erjhome/RubymineProjects/Amy_Natural_History'
directory_name = "#{root_directory}/notebook_7_8"
output_directory = "#{root_directory}/notebook_7_8b"
output_directory2 = "#{root_directory}/notebook_7_8b_md"

def notebookdocx_to_md(directory_name, output_directory)
  FileUtils.mkdir_p(output_directory) unless Dir.exist?(output_directory)
  Dir.chdir(directory_name)
  Dir.glob('**/*.docx').each { |docx|
    Dir.chdir(directory_name)
    path = File.realpath(docx)
    name = File.basename(docx, '.docx')
    Dir.chdir(output_directory)
    `pandoc -t markdown -o "#{name}.md" "#{path}"`
  }
end

def convert_name(directory_name, output_directory)
  Dir.chdir(directory_name)
  Dir.glob('**/*.docx').each { |docx|
    Dir.chdir(directory_name)
    name = File.basename(docx)
    path = File.realpath(docx)
    newname = name.gsub("section","entry")
    FileUtils.mv(path,output_directory+"/"+newname)
  }
end

#convert_name(directory_name, output_directory)
notebookdocx_to_md(output_directory, output_directory2)