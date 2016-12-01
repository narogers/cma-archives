# Just need to override the characterize method to make a call to the FITS
# servlet instead of invoking FITS on the command line. This should be a one
# line change to https://github.com/projecthydra/sufia/blob/6.x-stable/sufia-models/app/models/concerns/sufia/generic_file/characterization.rb#L71-L78
module CMA
  module GenericFile
    module Characterization
      def characterize
        metadata = (content.size < Sufia.config.characterization_service_limit) ?
          CMA::CharacterizationService.characterize(content) :
          content.extract_metadata
        characterization.ng_xml = metadata if metadata.present?
        append_metadata
        self.filename = [content.original_name]
        save
      end

      def import_exif_metadata
        return unless self.image?
      
        Hydra::Derivatives::TempfileService.create(content) do |f|
          exif = MiniExiftool.new f.path
        
          Sufia.config.exif_to_desc_mapping.each_pair do |node, field|
            next if exif[node].nil?

            metadata = normalize(exif[node])
            Rails.logger.info "[EXIF] Processing #{field.to_s}"

            self[field] = self[field].is_a?(Array) ? 
              metadata + self[field] : 
              metadata.join(" ")
          end
        end

        Sufia.config.default_metadata_fields.each_pair do |property, value|
          self[property] += [value].flatten unless self[property].include? value
        end
        save
      end

      private
        def normalize field
          properties = [field].flatten

          normalized_properties = []
          properties.each do |prop|
            prop = prop.to_s.gsub("|", "--")
            prop.gsub!(/[[:cntrl:]]/, "")

            normalized_properties += [prop]
          end

          normalized_properties
        end
    end
  end
end
