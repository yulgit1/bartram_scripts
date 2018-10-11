require 'httparty'

#for objects
url = "http://localhost:8983/solr/bertram2/select?fq=format%3Aobject&rows=5000&fl=id&wt=json&indent=true"

ids_array = Array.new
response = HTTParty.get(url)
response.parsed_response["response"]["docs"].each { |doc|
  ids_array.push(doc["id"])
}
IO.write("object_ids.txt", ids_array.join("\n"))


#for scans
url = "http://localhost:8983/solr/bertram2/select?fq=format%3Ascan&rows=5000&fl=id&wt=json&indent=true"

ids_array = Array.new
response = HTTParty.get(url)
response.parsed_response["response"]["docs"].each { |doc|
  ids_array.push(doc["id"])
}
IO.write("scan_ids.txt", ids_array.join("\n"))
