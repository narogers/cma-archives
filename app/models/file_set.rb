class FileSet < ActiveFedora::Base
  include CurationConcerns::FileSetBehavior
  include Sufia::FileSetBehavior
end
