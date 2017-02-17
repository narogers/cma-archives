class Collection < Sufia::Collection
  include Hydra::Collection

  include CMA::AdminPolicyBehavior
  include CMA::Collection::CollectionSize
  include CMA::Collection::CollectionType
  include CMA::Collection::Indexing
  include CMA::Collection::Metadata

  before_save :normalize_title

  # Be sure that if you want overrides for acronym they are set in
  # config/initializers/inflections.rb
  def normalize_title
    # Shift everything to lower case first so that improperly cased acronyms
    # don't split into two words and then apply the titlecase
    #
    # Kludge since WIBxxxx can't be handled properly as an inflection
    self.title = self.title.downcase.titlecase unless self.title.match(/^WIB\d+$/)
  end

  # Pass in a hash of keys that map to Solr fields. The method will then test
  # to see the collection contains an object that matches all of the criteria
  #
  # field: A hash containing a Solr field (key) and the value to test
  def find_children_by(fields)
    queries = []
    fields.each_pair do |k, v|
      solr_field = GenericFile.index_config[k.to_sym]
      next if solr_field.nil?

      index = Solrizer.solr_name(k, solr_field.behaviors.first)
      queries << "#{index}:\"#{v}\"" 
    end 
    query = queries.join(" ")
    limits = {
      fl: "id",
      fq: ["has_model_ssim:GenericFile",
           "{!join from=hasCollectionMember_ssim to=id}id:#{self.id}"],
    }
    ids = ActiveFedora::SolrService.query(query, limits)
    ids = ids.collect { |res| res["id"] }

    # Now return the set
    ids    
  end
end
