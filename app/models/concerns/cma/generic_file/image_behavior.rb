# Converts Solrized binary blobs back into binary streams
module CMA
  module GenericFile
    module ImageBehavior
      extend ActiveSupport::Concern

      def thumbnail_image
        Base64.decode64(self["thumbnail_ssm"])
      end

      def preview_image
        Base64.decode64(self["preview_ssm"])
      end
    end
  end
end
