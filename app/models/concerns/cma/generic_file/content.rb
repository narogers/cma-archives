module CMA
	module GenericFile
		module Content
			extend ActiveSupport::Concern

			included do
				contains 'content', class_name: 'CMAFileContentDatastream'
				contains 'access'
				contains 'thumbnail'
			end
			
		end
	end
end
