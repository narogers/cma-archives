
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
      "url" => generic_file.import_url,
      "file_size" => 0,
    }
    
    # Infer the MIME type from the file name since it was not
    # provided by any HTTP headers

    # Because of a bug with DNG files we need to coax MiniMagick into
    # loading the right library. Until a better solution comes along
    # the way to do this is by forcing an extension onto the file but
    # only for DNGs
    #
    # This is not perfect but it will work with 99% of the cases that
    # are present
    tmpfile = [pid.gsub('/', "_")]
    puts('w00t w00t')

    if (File.extname(uri.basename) == 'dng')
      mime_type = "image/x-adobe-dng"
      tmpfile.push('.dng')
    else
      mime_types = MIME::Types.of(uri.basename)
      mime_type = mime_types.empty? ? "application/octet-stream" : mime_types.first.content_type
      tmpfile.push('')
    end
    
    Tempfile.open(tmpfile) do |f|
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