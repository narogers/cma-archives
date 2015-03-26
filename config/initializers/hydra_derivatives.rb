require 'mini_magick'
require 'hydra/derivatives'

# Switch the default image handling library from ImageMagic to
# GrahicsMagick and explicitly set the path
MiniMagick.configure do |config|
  config.cli = :graphicsmagick
  config.cli_path = "/usr/bin"
end

Hydra::Derivatives::Image.module_eval do
  	 	# Transpose the format and yield commands so that it plays 
  	 	# nicely with RAW files
  	 	def create_image(output_file, format, quality=nil)
  	 		puts "[Derivatives] Using custom image conversion chain"
  	 		xfrm = load_image_transformer
  	 		xfrm.format(format)
  	 		yield(xfrm) if block_given?
  	 		xfrm.quality(quality.to_s) if quality
  	 		# No need to write since we are doing this in real time
  	 		# But if you are still using read or open then uncomment
  	 		# the next line
  	 		write_image(output_file, xfrm)
  	 	end

  	 	def load_image_transformer
  	 		MiniMagick::Image.open(source_file)
  	 	end
  	 end
