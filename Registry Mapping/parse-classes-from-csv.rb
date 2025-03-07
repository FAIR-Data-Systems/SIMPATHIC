
require 'csv'

# Step 1: Generate the unique identifiers
start_num = 12
end_num = 14500
prefix = "MotFunc_"
identifiers = (start_num..end_num).map { |num| "#{prefix}%05d" % num }

# Step 2: Read the first column from the input CSV
input_file = 'data.csv'  # Replace with your input CSV file path
first_column_values = []
begin
  first_column_values = CSV.foreach(input_file, headers: true).map { |row| row[0] if row[0] }
rescue Errno::ENOENT
  puts "Error: Input file '#{input_file}' not found."
  exit
rescue CSV::MalformedCSVError => e
  puts "Error: Invalid CSV format in '#{input_file}' - #{e.message}"
  exit
end

top = {}
f = File.open("test.owl", "w")

first_column_values.each do |label|
  next unless label
  next if top.keys.include? label
  funcid = identifiers.shift
  top[label] = funcid
  a = %Q{<owl:Class rdf:about="https://w3id.org/nmd-domain##{funcid}">
<rdfs:subClassOf rdf:resource="http://purl.obolibrary.org/obo/NCIT_C20993"/>
<rdfs:label xml:lang="en">#{label}</rdfs:label>
</owl:Class>\n\n}

  f.write a + "\n"

end

CSV.foreach(input_file, headers: true) do |row| # row[0] }
  next unless row[0]
  parentid = top[row[0]]
  thisid = identifiers.shift
  enmdlabel = row[1]; enmddef = row[2]
  dmslabel = row[3]; dmsdef = row[4]
  enddm1label = row[5]; enddm1def = row[6]
  myodraftlabel = row[7]; myodraftdef = row[8]
  hpolabel = row[11]; hpo = row[12]

  label = ""
  label = hpolabel if  hpolabel
  label = dmslabel if  dmslabel
  label = enmdlabel if  enmdlabel
  label = myodraftlabel if myodraftlabel
  label = enddm1label if enddm1label
  abort "label empty" unless label
  abort "label empty" if label.empty?

  description = ""
  description = description + "EURO-NMD: " + enmddef + "; " if enmddef
  description = description + "DM-Scope: " + dmsdef + "; " if dmsdef
  description = description + "END-DM1: " + enddm1def + "; " if enddm1def
  description = description + "Myodraft: " + myodraftdef + "; " if myodraftdef
  description = description + "HPO: " + hpo + " " + hpolabel + "; " if hpo
  abort "description empty" unless description


  metadata = ""
  metadata = metadata + "<dc:identifier>Myodraft: #{myodraftlabel}</dc:identifier>\n"  if myodraftlabel
  metadata = metadata + "<dc:identifier>END-DM1: #{enddm1label}</dc:identifier>\n"  if enddm1label
  metadata = metadata + "<dc:identifier>DM-Scope: #{dmslabel}</dc:identifier>\n"  if dmslabel
  metadata = metadata + "<dc:identifier>EURO-NMD: #{enmdlabel}</dc:identifier>\n"  if enmdlabel
  metadata = metadata + "<dc:identifier>HPO: #{hpo}</dc:identifier>\n"  if hpo
  
  a = %Q{<owl:Class rdf:about="https://w3id.org/nmd-domain##{thisid}">
<rdfs:subClassOf rdf:resource="https://w3id.org/nmd-domain##{parentid}"/>
<rdfs:label>#{label}</rdfs:label>
#{metadata}
</owl:Class>\n\n}

  f.write a + "\n"


end

puts "last identifier", identifiers.shift