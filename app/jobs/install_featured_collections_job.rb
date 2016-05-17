class InstallFeaturedCollectionsJob
  attr_accessor :collections

  def initialize(collections)
    self.collections = collections
  end

  def queue_name
    :collections
  end

  # If the collections parameter is a String infer that it is a path to
  # something on disk. Otherwise presume that you can just roll with the
  # data structure as is
  def run
    featured_collections = collections.is_a?(String) ?
      load_collections(collections) :
      collections 
    validate_collections featured_collections

    featured_collections.each do |fc|
      print "Preparing #{fc[:title]} ...\n"
      coll = create_or_find_collection(fc)
      create_featured_collection(coll.id)
    end
  end

  def create_or_find_collection(collection)
    collections_in_solr = ActiveFedora::SolrService.query(
       "primary_title_ssi:\"#{collection[:title]}\"", 
       {fq: "has_model_ssim:Collection"})
    coll = (0 == collections_in_solr.count) ?
      create_collection(collection) :
      collections_in_solr.first
    
    coll
  end

  def create_collection(collection)
    coll = Collection.new(
      title: collection[:title],
      description: collection[:description],
      depositor: "admin",
      edit_users: [:admin],
      edit_groups: [:admin],
    )
    coll.read_groups += [collection[:groups]] unless collection[:groups].blank?
    coll.save

    print "* Creating a new collection in the repository\n"

    coll
  end

  def create_featured_collection(collection_id)
    FeaturedCollection.create(collection_id: collection_id) unless
      FeaturedCollection.exists?(collection_id: collection_id)
    print "* FeaturedCollection has been created for #{collection_id}\n"  
  end
 
  def load_collections(yaml)
    collections = nil
    if File.exists? yaml
      collections = YAML.load_file(yaml)
      collections.map! { |c| c.symbolize_keys }
    else
      raise CMA::Exceptions::FileNotFoundError.new "Could not load #{yaml}"
    end
  end

  # Ensure that each collection hash object contains at a minimum a title
  # and description. If either is missing immediately raise an error then
  # halt processing
  def validate_collections(collections)
    collections.each do |c|
      if (c[:title].blank? or c[:description].blank?)
        raise CMA::Exceptions::MissingValueError.new "Provided collection values are missing a title and/or description"
      end
    end
  end
end
