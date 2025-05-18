require "json"
require "linkeddata"

PARAMS = "?apikey=74027bd8-6be0-4329-be22-aa3717f97243&format=json"

# http://data.bioontology.org/ontologies/SNOMEDCT/classes/http%3A%2F%2Fpurl.bioontology.org%2Fontology%2FSNOMEDCT%2F410607006
class NCBO
  attr_accessor :uri, :url

  def initialize(uri:)
    @uri = uri
    warn "#{@uri} isn't an NCBO  URI, don't expect this to work!" unless @uri =~ /bioontology\.org/

    root = "http://data.bioontology.org/ontologies/XXXXX/classes/"
    encoded = URI.encode_www_form_component uri

    return unless uri =~ /LNC/

    @url = root.gsub("XXXXX", "LOINC") + encoded + PARAMS
  end

  def lookup_title
    title = nil
    fullURL = "#{@url}?#{PARAMS}" # add API key and json directive
    if (json = resolve_url_to_json(url: @url, accept: "application/json"))
      title = find_title_in_json(json: json)
    end
    title
  end

  def find_title_in_json(json:)
    return "" unless json
    json["prefLabel"]
  end
end
