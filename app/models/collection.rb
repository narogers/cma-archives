class Collection < Sufia::Collection
  include Hydra::Collection
  include CMA::Collection::Featured
  include CMA::Collection::CollectionSize
  include CMA::Collection::CollectionType
  include CMA::Collection::Indexing
  include CMA::Collection::Metadata

  before_save do
    normalize_title
  end

  # Helper method to fix the casing of titles but retain certain acronyms
  #
  # Be sure that if you want overrides for acronym they are set in
  # config/initializers/inflections.rb
  def normalize_title
    # Shift everything to lower case first so that improperly cased acronyms
    # don't split into two words and then apply the titlecase
    self.title = self.title.downcase.titlecase
  end

  # Override default behaviour of making everything public to inherit the
  # permissions of the parent (if it is present). There's a danger here in
  # infinite loops that exists elsewhere in the code so tread with caution
  def update_permissions
    # Done this way because of a bug that pops up when the relationship has
    # yet to be defined. Otherwise the caller will get a nasty surprise
    if ([] == self.collections)
      # No OP
    end
      
    unless self.collections.blank? then
      parent = self.collections.first
      self.read_groups = parent.read_groups
      self.edit_groups = parent.edit_groups
    end
  end 

  # Pass in a hash of keys that map to Solr fields. The method will then test
  # to see the collection contains an object that matches all of the criteria
  #
  # field: A hash containing a Solr field (key) and the value to test
  def contains?(fields)
    queries = []
    fields.each_pair do |k, v|
      queries << "#{Solrizer.solr_name(k)}:\"#{v}\""
    end 
    query = queries.join(" ")
    limits = {
      fq: ["has_model_ssim:GenericFile",
           "{!join from=hasCollectionMember_ssim to=id}id:#{self.id}"],
      rows: 1
    }
    file_count = ActiveFedora::SolrService.count(query, limits)

    return file_count > 0
  end
end
