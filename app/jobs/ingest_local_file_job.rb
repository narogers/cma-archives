class IngestLocalFileJob < ActiveFedoraIdBasedJob
  # :nocov:
  def queue_name
    :ingest
  end
  # :nocov:

  def run
    uri = Addressable::URI.parse(generic_file.import_url)

    Rails.logger.info "[INGEST] Preparing #{generic_file.import_url} for processing"
    mime_types = MIME::Types.of(uri.basename)
    generic_file.mime_type = mime_types.empty? ? "application/octet-stream" : mime_types.first.content_type

    local_file = Derivatives::IoDecorator.new File.new(File::NULL)
    local_file.mime_type = "message/external_body; access-type=URL; url=\"#{local_file_url(generic_file)}\""

    generic_file.add_file(local_file, {path: 'content', original_name: uri.basename, mime_type: local_file.mime_type})
    generic_file.label ||= uri.basename
    generic_file.title += [generic_file.label] if generic_file.title.empty?
    generic_file.save

    IngestFileIntoLocalRepositoryService.ingest(generic_file)
    Sufia.queue.push(ProcessImportedFileJob.new(generic_file.id)) 
  end

  def local_file_url resource
    LocalFileUrlService.download_url resource
  end
end
