require 'ruby-vips'

module Hydra::Derivatives
  class VipsImage < Image
    class_attribute :timeout

    def process_without_timeout
      directives.each do |name, args|
        opts = args.kind_of?(Hash) ? args : {height: args}
        format = opts.fetch(:format, 'jpg')
        output_file_name = opts.fetch(:datastream, output_file_id(name))
        create_resized_image output_file(output_file_name), format, opts
      end
    end

    def create_resized_image output_file, format, opts
      img_derivative = create_image output_file, format, opts
      write_image output_file, img_derivative, opts
      output_file.mime_type = new_mime_type(format)
      output_file.original_name = "derivative.#{format}"
    end

    # Relies on VIPS instead of ImageMagick / GraphicsMagick to do processing
    # with a simplified chain that makes several assumptions. The crops are
    # done in two passes to ensure that the width and scale are correct in lieu
    # of making a long narrow image for unusually wide images
    #
    # Aspect ratio is maintained as 2:3 so that if size is set to 400 pixels
    # the width will be no more than 600 pixels 
    def create_image output_file, format, opts
      width = opts.fetch(:width, opts[:height]*1.5)

      if (opts[:crop])
        img_derivative = Vips::Image.thumbnail_buffer(source_file.content,
          1000000, height: opts[:height], auto_rotate: true)
        # Centre is used for smartcrop due to an issue with JPEGs that will
        # otherwise break the process with an Out of Tile error
        if (width < img_derivative.width)
          img_derivative = img_derivative.smartcrop(width, opts[:height],
            interesting: 'centre')
        end
      else
        img_derivative = Vips::Image.thumbnail_buffer(source_file.content,
          width, height: opts[:height], auto_rotate: true)
      end
  
      return img_derivative
    end
  
    def write_image output_file, image, opts
      extension = opts.fetch(:format, "png")
      format = ".#{extension}"
      strip_flag = opts.fetch(:strip_metadata, false)

      buffer = image.write_to_buffer(format, strip: strip_flag)
      output_file.content = buffer
    end
  end
end
