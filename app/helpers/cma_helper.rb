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

  # See http://codepen.io/css_librarian/pen/PZaZzg for demonstration of the next
  # two methods in action
  def render_collection_thumbnail collection
    content_tag :div, class: "collection-icon" do
      content_tag :span, class: "fa-stack fa-5x" do
        concat content_tag :i, "", class: "fa fa-folder fa-stack-2x"
        concat collection_icon_for collection
      end
    end
  end 

  # TODO: Define these settings in a configuration file instead of here
  def collection_icon_for collection
    icon = ""
    if collection.has_audio?
      icon = "fa-volume-up"
    elsif collection.has_images?
      icon = "fa-photo"
    elsif collection.has_video?
      icon = "fa-video-camera"
    elsif collection.has_pdfs?
      icon = "fa-archive"
    else
      # Unknown so default to nothing
    end
  
    icon.present? ? content_tag(:i, "", {class: "fa #{icon} fa-stack-1x fa-inverse"}) : ""
  end 

  # Maybe this could be done as a presenter instead but for the first prototype
  # just use a simple helper
  #
  # date should be a string representation
  def formatted_date_for raw_date, format=:concise
    return "Not available" if raw_date.empty?

    parsed_date = Date.parse(raw_date)
    parsed_date.to_formatted_s(format)
  end

  # Sibling to Sufia's display_multiple that renders only the first value
  def display_primary(value)
    if value.is_a? Array
      value.first
    else
      value
    end
  end

  # Thumbnail method for gallery view(s)
  def preview_thumbnail_tag(document, options)
    if document.collection?
      render_collection_thumbnail document
    else
      path = 
        if document.image?
          sufia.download_path document, file: "thumbnail"
        elsif document.audio?
          "audio.png"
        else
          "default.png"
        end
      image_tag path, options
    end
  end
end

