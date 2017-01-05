class InstallAdministrativeCollectionsJob
  attr_accessor :collections

  def initialize(collections)
    self.collections = collections
  end

  # :nocov:
  def queue_name
    :install
  end
  # :nocov:

  def run
    admin_collections = collections.is_a?(String) ?
      load_policies(collections) :
      collections
    validate admin_collections

    admin_collections.each { |coll| create_or_update_collection(coll) }
  end

  def create_or_update_collection(collection)
    count = AdministrativeCollection.count(conditions: "#{title_field}: \"#{collection[:title]}\"")
    (0 == count) ?
      create_collection(collection) :
      update_collection(collection)
  end

  def create_collection(collection)
    puts "* Creating administrative collection for #{collection[:title]}"
    admin_collection = AdministrativeCollection.create(
      title: [collection[:title]],
      description: [collection[:description]])
    set_default_permissions admin_collection, collection
  end

  def update_collection collection
    puts "* Updating administrative collection for #{collection[:title]}"
    admin_collection = AdministrativeCollection.where(title_field => collection[:title]).first
    set_default_permissions admin_collection, collection
  end

  def set_default_permissions collection, permissions
    AdministrativeCollection.permission_groups.each do |role|
      next if permissions[role].nil?
      apply_default_permissions(collection, role, 
        permissions[role].split(" "))
    end 
    collection.save
  end

  def load_policies(yaml)
    policies = nil
    if File.exists? yaml
      policies = YAML.load_file(yaml)
      policies.map! { |c| c.symbolize_keys }
    else
      raise CMA::Exceptions::FileNotFoundError.new "Could not load #{yaml}"
    end
  end

  def validate(collections)
    collections.each do |coll|
      if (coll[:title].blank? or coll[:description].blank?)
        raise CMA::Exceptions::MissingValueError.new "Provided collection defaults are missing a title and/or description"
      end
    end
  end

  def title_field
    ActiveFedora::SolrQueryBuilder.solr_name("title").to_sym
  end

  def apply_default_permissions(admin_collection, role, members=nil)
    return if members.nil?

    admin_collection.send("#{role.to_s}_groups=", members)
    members.each do |member|
      admin_collection.default_permissions.create(type: "group", 
        access: role.to_s, name: member) 
    end 
  end 
end
