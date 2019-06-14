require 'httparty'

#for scans
url = "http://10.5.96.214:8983/solr/bartram3/select?fq=format%3Ascan&rows=5000&fl=id&wt=json&indent=true"

ids_array = Array.new
response = HTTParty.get(url)
response.parsed_response["response"]["docs"].each { |doc|
  ids_array.push(doc["id"])
}

ids_array.each_with_index do |id,i|
  #break if i > 2
  url = "http://10.5.96.214:8983/solr/bartram3/select?fq=id%3A#{id}&fl=*&wt=json&indent=true"
  response = HTTParty.get(url)
  doc = response.parsed_response["response"]["docs"][0]
  file = "updated_scans1/" + doc["id"] + ".txt"
  IO.write("#{file}", doc)
end