# Very similar to the regular Source File Service except that we first set the
# local path, if present, so that CMAFileContentDatastream can do its magic to proxy
# a local copy in lieu of going to Fedora
class LocalSourceFileService < Hydra::Derivatives::TempfileService
  def self.call(object, source_name, &block) 
     datastream = object.send(source_name)
     # Assumes that these properties exist on the object
     datastream.local_path = object.import_url.sub("file://", "") if object.respond_to? :import_url

     return datastream
  end
end
