module CMA
	module GenericFile
		module Content
			extend ActiveSupport::Concern

			included do
				has_subresource 'content', 
                  class_name: 'CMAFileContentDatastream'
				has_subresource 'access'
				has_subresource 'thumbnail'
			end
			
		end
	end
end
