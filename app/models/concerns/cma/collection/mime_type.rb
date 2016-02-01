# Based on the assumption that the contents of a collection are
# homogenous this module will report what type of media is present
# in a collection.
module CMA
  module Collection
    module MimeType
      extend ActiveSupport::Concern
      def has_audio?
        contains_mime_types ::GenericFile.audio_mime_types
      end

      def has_video?
        contains_mime_types ::GenericFile.video_mime_types
      end

      def has_images?
        contains_mime_types ::GenericFile.image_mime_types
      end
 
      def has_pdfs?
        contains_mime_types ::GenericFile.pdf_mime_types
      end
  
      def contains_mime_types mime_types
        # Instead of treating a nil value as a wild card treat it as an 
        # edge case
        return false if mime_types.empty?

        query = "*:*"
        limits = {fq: ["has_model_ssim:GenericFile",
          "{!join from=hasCollectionMember_ssim to=id}id:#{self.id}", 
          "mime_type_ssim:(#{mime_types.join(" ")})"]}
        matches = ActiveFedora::SolrService.count(query, limits)
        
        return matches > 0 
      end
    end
  end
end
