require 'ruby-vips'
require 'pry'

module Hydra::Derivatives
  class VipsLayeredImage < VipsImage
    def create_image output_file, format, opts
      width = opts.fetch(:width, opts[:height]*1.5)
   
      img_derivative = nil
      TempfileService.create(source_file) do |tmp|
        if (opts[:crop])
          img_derivative = Vips::Image.thumbnail("#{tmp.path}[0]",
            1000000, height: opts[:height], auto_rotate: true)
          # Centre is used for smartcrop due to an issue with JPEGs that will
          # otherwise break the process with an Out of Tile error
          if (width < img_derivative.width)
            img_derivative = img_derivative.smartcrop(width, opts[:height],
              interesting: 'centre')
          end
        else
          img_derivative = Vips::Image.thumbnail("#{tmp.path}[0]",
            width, height: opts[:height], auto_rotate: true)
        end
      end

      return img_derivative
    end
  end
end
