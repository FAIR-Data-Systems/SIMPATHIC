require 'json'
require 'rest-client'
require_relative './obo.rb'
require 'linkeddata'
require 'sparql/client'

class UNIPROT
  attr_accessor :uri, :url

  PARAMS = "apikey=#{ENV['APIKEY']}&format=json".freeze

ENSGQUERY = "
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX uniprotkb: <http://purl.uniprot.org/uniprot/>
PREFIX taxon: <http://purl.uniprot.org/taxonomy/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX up: <http://purl.uniprot.org/core/>
#SELECT ?protein ?fullName ?prefLabel ?recommended ?gene
SELECT distinct ?protein ?tax ?pref ?alt ?recommended_full
WHERE
{
        ?protein a up:Protein .
        ?protein up:reviewed true .
#  		?protein rdfs:seeAlso ?other .
#  		?other rdfs:comment ?alt_name .
  		?protein up:organism ?tax .
  OPTIONAL {?protein up:recommendedName ?rname . ?rname up:fullName ?recommended_full }
		?protein rdfs:seeAlso |||ENSG||| .
  OPTIONAL {  		?protein skos:prefLabel ?pref }
  OPTIONAL {		?protein skos:altLabel ?alt }
} LIMIT 10"

  def initialize()
  end

  def search_by_ensgene(ensg:)
    sparql = SPARQL::Client.new("https://sparql.uniprot.org/sparql/")
    unless ensg =~ /proteinatlas/
      # ensg = "<http://www.proteinatlas.org/#{ensg}>"
      ensg = "<http://purl.uniprot.org/opentargets/#{ensg}>" # open targets is more reliable?
    end
  
    # warn "gene name #{ensg}"
    result = nil
    retry_attempts = 1
    begin
      # warn ENSGQUERY.gsub("|||ENSG|||", ensg)
      result = sparql.query(ENSGQUERY.gsub("|||ENSG|||", ensg),
      read_timeout: 300, # 5 minutes
      open_timeout: 60   # 1 minute
      )
    rescue StandardError => e
      warn e.inspect
      retry_attempts += 1
      if retry_attempts < 10
        retry
      else
        puts "Timeout error"
        abort
      end
    end
    if result.first
      # SELECT distinct ?protein ?tax ?pref ?alt ?recommended_full

      res = result.first  # first to get the recommended label
      [res[:protein].to_s, res[:tax].to_s, res[:recommended_full].to_s]
    end
  end
end