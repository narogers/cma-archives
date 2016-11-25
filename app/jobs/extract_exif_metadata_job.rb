# Run this job on images to pull out any metadata which will be
# mapped to the descriptive metadata fields based on the settings
# in exiftool_to_desc_mappings in config/initializers/sufia.rb
#
# If this is not set, or the content is not recognized as an image,
# then nothing exciting will happen
class ExtractExifMetadataJob < ActiveFedoraIdBasedJob
  # :nocov:
  def queue_name
    return :exif_metadata
  end
  # :nocov:
  
  def run
    Rails.logger.info "[EXIF] Extracting EXIF headers for #{generic_file.id}"
    return unless generic_file.content.has_content?
    return unless generic_file.image?

    generic_file.import_exif_metadata  
  end
end
