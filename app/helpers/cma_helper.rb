module CMAHelper
  def render_partial_for(partial, member=nil)
    root_path = member.class.to_s.underscore

    # This should look something like collection/collection/row
    # or collection/generic_file/row
    partial = "collections/#{root_path}#{File::Separator}#{partial}"

    render partial, {member: member}
  end

  # Given a collection object will choose either the description field,
  # if present, or the path for the folder. This is a bit of a bandaid
  # patch until the metadata can be updated
  #
  # TODO: Consider using a presenter
  def description_for_collection collection
     description = 'No description available'
     if collection.description.present?
       description = collection.description
     else
       first_member = collection.members.first
       unless first_member.nil?
         description = File.dirname(first_member.import_url)
         description = Addressable::URI.parse(description).path
       end
     end

     return description
  end

  # Renders a thumbnail that links to the larger preview version of an image
  def render_preview_icon source=nil
    source ||= "default.png"
    image_tag sufia.download_path(@generic_file, file: "thumbnail"), 
      alt: "Load preview image in browser", 
      class: "img-responsive"
  end
end
