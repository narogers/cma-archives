# Run this after setting permissons on parent collections to push their
# effects to the children in the background. This works because of the
# before_save method in the Collection class that triggers the resolution of
# permissions
class ReindexCollectionPermissionsJob 
  queue_as :permissions

  def perform
    Collection.find_each do |coll|
      Rails.logger.info "[PERMISSIONS] Updating #{coll.title} (#{coll.id})"
      coll.save
    end 
  end
end
