require 'mini_magick'

module Hydra::Derivatives
  class ExifImage < Image
    class_attribute :timeout
  
    # No longer a need to override create_image or remove_temp_files
    # if we can extract the thumbnmail that is already embedded in the
    # RAW container. As an added bonus this will go very quickly compared
    # to rescaling a 40MB DNG file
    def load_image_transformer
      tmp_master = Tempfile.new([object.id, ".dng"])
      tmp_master.binmode
      tmp_master.write(source_file.content)

      xfrm = nil
      # Attempt to extract the thumbnail. If this fails then return the full
      # blown image instead
      if (system("dcraw", "-e", tmp_master.path))
        tmp_thumbnail_path = tmp_master.path.sub ".dng", ".thumb.jpg"
        xfrm = MiniMagick::Image.open tmp_thumbnail_path
        FileUtils.rm tmp_thumbnail_path
      else
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
