class ProcessImportedFileJob < ActiveJob::Base
  queue_as :process

  def perform(file_id)
    generic_file = GenericFile.find file_id
    Rails.logger.info "[PROCESS] Characterizing #{generic_file.id}"
    generic_file.characterize

    Rails.logger.info "[PROCESS] Creating derivatives for #{generic_file.id}"
    generic_file.create_derivatives
 
    if generic_file.image?
      Rails.logger.info "[PROCESS] Extracting EXIF metadata for #{generic_file.id}"
      generic_file.import_exif_metadata
    end
  end
end
