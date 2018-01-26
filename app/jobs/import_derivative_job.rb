# Allows for derivatives to be imported from an external source instead
# of generated internally
class ImportDerivativeJob
  attr_accessor :id, :derivative, :path

  #:nocov:
  def queue_name
    :import_derivative
  end
  #:nocov:

  def initialize(id, derivative, path)
    self.id = id
    self.derivative = derivative
    self.path = path
  end

  def run
    Rails.logger.info("[IMPORT DERIVATIVE] Importing external derivative for #{id} from #{path}")

    if "content" == derivative
      Rails.logger.warn "[IMPORT DERIVATIVE] Trying to overwrite the original resource. Import will be ignored"
      return
    end

    unless File.exists? File.expand_path(path)
      raise CMA::Exceptions::FileNotFoundError.new "Unable to locate file at #{path}"
    end

    gf = GenericFile.find id
    file = File.binread File.expand_path((path))
    parsed_mime_type = MIME::Types.type_for(File.basename(path)).first

    gf[derivative].content = file
    gf[derivative].mime_type = parsed_mime_type.nil? ?
      "application/octet-stream" :
      parsed_mime_type.content_type
    gf[derivative].original_name = File.basename(path)
    gf.save
  end 
end
