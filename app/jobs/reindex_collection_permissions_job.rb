# Run this after setting permissons on parent collections to push their
# effects to the children in the background. This works because of the
# before_save method in the Collection class that triggers the resolution of
# permissions
class ReindexCollectionPermissionsJob 
  def queue_name
    :permissions
  end

  def run
    # Collection.find_each is marginally faster than the alternatives for
    # now and possibly less memory intensive
    Collection.find_each do |coll|
      Resque.logger.info "[PERMISSIONS] Updating #{coll.title} (#{coll.id})"
      coll.save
    end 
  end
end
