require "json"
require "rest-client"

abort "\n\nusage:  ruby mesh_lookup.rb  MESH inputfile.txt > output.csv\n\n" unless ARGV[0] && ARGV[1]
abort "\n\nusage:  You must set your OBO API key in the APIKEY environment variable\n\n" unless ENV['APIKEY']


PARAMS = "?apikey=#{ENV['APIKEY']}&format=json"
ONTOLOGY=ARGV[0]
# perma id:  http://purl.bioontology.org/ontology/MESH/D000602
# redirect: https://bioportal.bioontology.org/ontologies/MESH?p=classes&conceptid=D000602

class NCBO
  attr_accessor :uri, :url

  def initialize(uri:)
    @uri = uri
    warn "#{@uri} isn't an NCBO  URI, don't expect this to work!" unless @uri =~ /bioontology\.org/

    root = "http://data.bioontology.org/ontologies/XXXXX/classes/"
    encoded = URI.encode_www_form_component uri

    @url = root.gsub("XXXXX", ONTOLOGY) + encoded + PARAMS
    # warn "final URL is #{@url}"
  end

  def lookup_title
    fullurl = "#{@url}?#{PARAMS}" # add API key and json directive
    json = RestClient.get(fullurl)
    find_title_in_json(json: json)
  end

  def find_title_in_json(json:)
    j = JSON.parse(json)
    # warn j["prefLabel"]
    j["prefLabel"]
  end
end

File.open(ARGV[1]).each do |line|
  id = line.strip
  next if id.empty?
  uri = "http://purl.bioontology.org/ontology/MESH/#{id}"
  n = NCBO.new(uri: uri)
  term = n.lookup_title
  puts term
end
