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
    featured_collections.each_with_index do |fc|
      print "Preparing #{fc['name']} ...\n"
      coll = create_or_find_collection(fc)
      create_featured_collection(coll.id)
    end
  end

  def create_or_find_collection(collection)
    collections_in_solr = ActiveFedora::SolrService.query(
       "primary_title_ssi:\"#{collection["title"]}\"", 
       {fq: "has_model_ssim:Collection"})
    coll = (0 == collections_in_solr.count) ?
      create_collection(collection) :
      collections_in_solr.first
    
    coll
  end

  def create_collection(collection)
    coll = Collection.create(
      title: collection['title'],
      description: collection['description'],
      depositor: "admin",
      edit_users: [:admin],
      edit_groups: [:admin],
      read_groups: [collection["groups"]]
    )
    print "* Creating a new collection in the repository\n"

    coll
  end

  def create_featured_collection(collection_id)
    FeaturedCollection.create(collection_id: collection_id) unless
      FeaturedCollection.exists?(collection_id: collection_id)
    print "* FeaturedCollection has been created for #{collection_id}\n"  
  end
 
  def load_collections(yaml)
    YAML.load_file(yaml)
  end
end
