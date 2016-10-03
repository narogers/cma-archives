# Override the ImportURLJob to support BrowseEverything
# retrievers rather than home grown code. Eventually this
# needs to get created as a pull request but this is just a
# prototype
#
# It might be wise to only encode if the URL is file:///
# based.
class ImportUrlJob < ActiveFedoraIdBasedJob
  def queue_name
    :import
  end

  def run
    user = User.find_by_user_key(generic_file.depositor)
    uri = Addressable::URI.parse(generic_file.import_url)

    spec = {
      "url" => generic_file.import_url,
      "file_size" => 0,
    }
    
    Rails.logger.info "[IMPORT URL] Preparing #{generic_file.import_url} for processing"
    mime_types = MIME::Types.of(uri.basename)
    generic_file.mime_type = mime_types.empty? ? "application/octet-stream" : mime_types.first.content_type
    tmp_file = [id] 
    tmp_file << ".#{mime_types.first.extensions.first}" unless mime_types.blank?   
    # Can't use TempfileService here because we are trying to
    # ingest the content into Fedora and that method assumes
    # that it is already there
    Tempfile.open(tmp_file) do |f|
      Rails.logger.info "[IMPORT URL] Storing temporary copy as #{f.path}"
      # Use BrowseEverything instead of a built in method
      retriever = BrowseEverything::Retriever.new
      retriever.download(spec, f)

      # Don't pass a message through Mailboxer any more; if the status
      # fails it can be handled differently in a future refactor of the
      # jobs workflow
      Sufia::GenericFile::Actor.new(generic_file, user).create_content(f, uri.basename, 'content', generic_file.mime_type)
    end
  end
end
