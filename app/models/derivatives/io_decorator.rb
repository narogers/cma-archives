# This probably needs a different home once the proof of concept works
# even though it is temporary until Hydra::Derivatives can be upgraded to
# version 2.x+
require 'delegate'

module Derivatives
  class IoDecorator < SimpleDelegator
    attr_accessor :mime_type, :original_name
 
    def initialize(file, mime_type = nil, original_name = nil)
      super(file)
      self.mime_type = mime_type
      self.original_name = original_name
    end   
  end
end
