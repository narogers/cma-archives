module CMAHelper
  def render_partial_for(partial, model)
    # This should look something like collection/collection/row
    # or collection/generic_file/row
    partial = "collections/#{model.model_class.to_s.underscore}#{File::Separator}#{partial}"
    render partial, {model: model}
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
  def collection_thumbnail_for(collection)
    classes = current_user.can?(:read, collection) ?
              "collection-icon" :
              "collection-icon disabled"
   
    icon =   
      if collection.has_audio?
        "volume-up"
      elsif collection.has_images?
        "photo"
      elsif collection.has_video?
        "video-camera"
      elsif collection.has_pdfs?
        "archive"
      else
        nil
      end

    content_tag :div, class: classes do
      content_tag :span, class: "fa-stack fa-5x" do
        concat content_tag :i, "", class: "fa fa-folder fa-stack-2x"
        concat content_tag(:i, "", {class: "fa fa-#{icon} fa-stack-1x fa-inverse"}) if icon.present?
      end
    end
  end 

  # Thumbnail method for gallery view(s)
  def preview_thumbnail_tag(document, options)
    if document.collection?
      collection_thumbnail_for document
    else
      path = 
        if document.image?
          sufia.download_path(document, file: "thumbnail")
        elsif document.audio?
          "audio.png"
        else
          "default.png"
        end
      image_tag path, options
    end
  end

  # Helper block for pagination
  def fa_icon(icon)
    content_tag :i, class: "fa fa-{icon}"
  end
end

