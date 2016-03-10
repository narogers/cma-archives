require 'mini_magick'

module Hydra::Derivatives::Processors
  class ExifImage < Image
    class_attribute :timeout
  
    # No longer a need to override create_image or remove_temp_files
    # if we can extract the thumbnmail that is already embedded in the
    # RAW container. As an added bonus this will go very quickly compared
    # to rescaling a 40MB DNG file
    def load_image_transformer
      binding.pry
      super
    end
  end
end
