class ProcessImportedFileJob < ActiveFedoraIdBasedJob
  # :nocov:
  def queue_name
    return :ingest
  end
  # :nocov:

  def run
    Rails.logger.info "[INGEST] Characterizing #{generic_file.id}"
    generic_file.characterize

    Rails.logger.info "[INGEST] Creating derivatives for #{generic_file.id}"
    generic_file.create_derivatives
 
    if generic_file.image?
      Rails.logger.info "[INGEST] Extracting EXIF metadata for #{generic_file.id}"
      generic_file.import_exif_metadata
    end
  end
end
