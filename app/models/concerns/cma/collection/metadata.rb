module CMA
  module Collection
    module Metadata
      extend ActiveSupport::Concern
      include Hydra::Collections::Metadata
 
      # Put any CMA specific metadata here
    end
  end
end
