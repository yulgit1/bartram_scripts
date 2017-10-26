require 'json'
require 'rsolr'

root_directory = '/Users/erjhome/RubymineProjects/Amy_Natural_History'
image_directory = "#{root_directory}/images"
solr_directory = "#{root_directory}/component_md/solrscans"
url_prefix = 'http://ec2-54-91-198-228.compute-1.amazonaws.com:3000'
solr_url = 'http://127.0.0.1:8983/solr/bertram1'

#configuration notes
#this isn't used, instead using parse_md2 to pull scan metadata into the object
#
#if this were to be used, uncomment solr connect, add, and commit lines to index

def index_scans(image_directory, url_prefix, solr_url,solr_directory)
  #solr = RSolr.connect :url => solr_url
  Dir.chdir(image_directory)
  Dir.glob('**/metadata-*.json').each { |md|
    puts md
    Dir.chdir(image_directory)
    metadata = JSON.parse(File.read(md))
    doc = Hash.new
    doc[:scan_title_s] = metadata['label']
    doc[:scan_title_t] = metadata['label']
    doc[:scantext_t] = "#{metadata['label']} #{metadata['recto']} #{metadata['verso']}"
    doc[:scan_subject_s] = metadata['subject']
    doc[:scan_subject_t] = metadata['subject']
    doc[:scan_author_s] = metadata['creator']
    doc[:scan_author_t] = metadata['creator']
    #doc[:timestamp] = Time.now.utc
    doc[:iiif_manifest_s] = "#{url_prefix}/manifest/#{metadata['id']}"
    doc[:iiif_thumbnail_s] = "#{url_prefix}/iiif/#{metadata['id'].gsub('scan','image')}-00"
    doc[:scan_part_of_s] = metadata['within']
    doc[:scan_part_of_s] = metadata['within']
    doc[:scan_location_s] = metadata['location']
    doc[:scan_location_t] = metadata['location']
    doc[:scan_contents_s] = metadata['contents']
    doc[:scan_recto_s] = metadata['recto']
    doc[:scan_verso_s] = metadata['verso']
    doc[:scan_photo_s] = metadata['photo']
    doc[:scan_institutional_stamp_s] = metadata['institutional_stamp']
    #solr.add doc
    bn = File.basename(md)
    file = File.open("#{solr_directory}/#{bn}", 'w')
    file.write(doc)
    file.close
  }
  #solr.commit
end

index_scans(image_directory, url_prefix, solr_url,solr_directory)