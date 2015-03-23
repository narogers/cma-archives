
# Override the ImportURLJob to support BrowseEverything
# retrievers rather than home grown code. Eventually this
# needs to get created as a pull request but this is just a
# prototype
#
# It might be wise to only encode if the URL is file:///
# based.
class ImportUrlJob < ActiveFedoraPidBasedJob
  def run
    user = User.find_by_user_key(generic_file.depositor)
    uri = Addressable::URI.parse(generic_file.import_url)

    spec = {
      "url" => uri.display_uri,
      "file_size" => 0,
    }
    
    # Infer the MIME type from the file name since it was not
    # provided by any HTTP headers
    mime_types = MIME::Types.of(uri.basename)
    mime_type = mime_types.empty? ? "application/octet-stream" : mime_types.first.content_type

    Tempfile.open(pid.gsub('/', '_')) do |f|
      # Use BrowseEverything instead of a built in method
      retriever = BrowseEverything::Retriever.new
      retriever.download(spec, f)

      if Sufia::GenericFile::Actor.new(generic_file, user).create_content(f, uri.basename, 'content', mime_type)
        message = "The file (#{generic_file.label}) was successfully imported."
        User.batchuser.send_message(user, message, 'File import')
      else
        User.batchuser.send_message(user, generic_file.errors.full_messages.join(", "), 'File Import Error')
      end
    end
  end
end