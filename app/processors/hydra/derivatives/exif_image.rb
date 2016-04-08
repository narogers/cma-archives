require 'mini_magick'

module Hydra::Derivatives
  class ExifImage < Image
    class_attribute :timeout

    def create_resized_image destination_name, size, format, quality=nil
      create_image(destination_name, format, quality) do |xfrm|
        xfrm.thumbnail(size) if size.present?
        xfrm.strip
      end
    end

    # No longer a need to override create_image or remove_temp_files
    # if we can extract the thumbnmail that is already embedded in the
    # RAW container. As an added bonus this will go very quickly compared
    # to rescaling a 40MB DNG file
    def load_image_transformer
      extension = File.extname(object.import_url)
      tmp_master = Tempfile.new([object.id, extension])
      tmp_master.binmode
      tmp_master.write(source_file.content)

      xfrm = nil
      # Attempt to extract the thumbnail. If this fails then return the full
      # blown image instead
      if (system("dcraw", "-e", tmp_master.path))
        Rails.logger.info "[DERIVATIVES] Extracted thumbnail image for #{object.id}"
        # The path can be either .jpg or .ppm so if it doesn't exist we just
        # switch to the other extension. JPEG is more common with RAW files
        # which is why it is currently the default
        tmp_thumbnail_path = tmp_master.path.sub extension, ".thumb.jpg"
        if !(File.exists? tmp_thumbnail_path)
          tmp_thumbnail_path.sub! ".jpg", ".ppm"
        end

        xfrm = MiniMagick::Image.open tmp_thumbnail_path
        FileUtils.rm tmp_thumbnail_path
      else
        Rails.logger.info "[DERIVATIVES] Using RAW master to generate derivatives for #{object.id}"
        xfrm = MiniMagick::Image.open tmp_master.path
      end

      # Unlink the temporary file to free up space since this is not in a
      # block
      tmp_master.unlink
      
      # Return either the small thumbnail or the full blown master
      xfrm
    end
  end
end
