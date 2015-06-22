class CmaImage < Hydra::Derivatives::Image
	protected
		# Override the create_resized_image method to use scale() 
		# which plays nicely with DNG images
		def create_resized_image(output_file, size, format, quality = nil)
			create_image(output_file, format, quality) do |xfrm|
				xfrm.scale(size) if size.present?	
			end
			output_file.mime_type = new_mime_type(format)	
		end

		# Override the image loading method to append a helpful hint 
		# for ImageMagick for certain file formats like DNG
		def load_image_transformer
			path = source_file.content
			extension = MIME::Types[source_file.mime_type].first.extensions.first
			path += ".#{extension}" unless extension.nil?

			MIniMagick::Image.read(path)
		end
end
