class Fixity
  def initialize(id)
    solr_resource = GenericFile.load_instance_from_solr(id)
    
    @remote_digest = {uri: "#{solr_resource.uri}/content/fcr:fixity"}
    @local_digest = {path: solr_resource.import_url.sub("file://", "")}
  end

  def remote
    if @remote_digest[:checksum].nil?
      RDF::Reader.open(@remote_digest[:uri]) do |reader|
        reader.each_statement do |triple|
          if triple.predicate.eql? RDF::Vocab::PREMIS.hasMessageDigest
            digest = triple.object.value
            scheme, algorithm, checksum = digest.split(":")

            @remote_digest[:algorithm] = algorithm
            @remote_digest[:checksum] = checksum
          end
        end
      end
    end

    @remote_digest
  end

  def local
    @local_digest[:algorithm] ||= 'sha1'
    
    if @local_digest[:checksum].nil?
      @local_digest[:checksum] = Digest::SHA1.file(@local_digest[:path])
    end

    @local_digest 
  end

  def equal?
    (local[:algorithm] == remote[:algorithm]) &&
    (local[:checksum] == remote[:checksum])
  end
end
