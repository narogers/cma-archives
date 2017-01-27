# Run this job on images to pull out any metadata which will be
# mapped to the descriptive metadata fields based on the settings
# in exiftool_to_desc_mappings in config/initializers/sufia.rb
#
# If this is not set, or the content is not recognized as an image,
# then nothing exciting will happen
class ExtractExifMetadataJob < ActiveJob::Base
  queue_as :exif_metadata
  
  def perform(file_id)
    Rails.logger.info "[EXIF] Extracting EXIF headers for #{file_id}"
    begin
      generic_file = GenericFile.find file_id
    rescue Ldp::Gone => error
      Rails.logger.info "[EXIF] Found a tombstone for #{file_id} instead of a file"
      raise error
    end

    return unless generic_file.content.has_content?
    return unless generic_file.image?

    generic_file.import_exif_metadata  
  end
end
