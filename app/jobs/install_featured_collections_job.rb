class InstallFeaturedCollectionsJob
  attr_accessor :collections

  def initialize(collections)
    self.collections = collections
  end

  def queue_name
    :collections
  end

  def run
    featured_collections = collections.is_a?(String) ?
      load_collections(collections) :
      collections 
    validate_collections featured_collections

    featured_collections.each do |featured|
      create_or_update_collection(featured)
    end
  end

  def create_or_update_collection(collection)
    count = Collection.count(conditions: "title_tesim: \"#{collection[:title]}\"")
    (0 == count) ?
      create_collection(collection) :
      update_collection(collection)
  end

  def create_collection(collection)
    puts "* Creating #{collection[:title]}"
    coll = Collection.new(
      title: collection[:title],
      description: collection[:description],
      depositor: "admin",
      edit_users: [:admin],
      edit_groups: [:admin],
    )
    coll.read_groups += [collection[:groups]] unless collection[:groups].blank?
    coll.save
    FeaturedCollection.create(collection_id: coll.id)

    coll
  end

  def update_collection collection
    puts "* Updating #{collection[:title]}"
    coll = ActiveFedora::SolrService.query("title_tesim: \"#{collection[:title]}\"", {rows: 1, fl: "id", fq: "has_model_ssim:Collection"}).first
    FeaturedCollection.find_or_create_by(collection_id: coll["id"])
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

  def validate_collections(collections)
    collections.each do |c|
      if (c[:title].blank? or c[:description].blank?)
        raise CMA::Exceptions::MissingValueError.new "Provided collection values are missing a title and/or description"
      end
    end
  end
end
