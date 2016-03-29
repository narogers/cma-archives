# Just need to override the characterize method to make a call to the FITS
# servlet instead of invoking FITS on the command line. This should be a one
# line change to https://github.com/projecthydra/sufia/blob/6.x-stable/sufia-models/app/models/concerns/sufia/generic_file/characterization.rb#L71-L78
module CMA
  module GenericFile
    module Characterization
      def characterize
        metadata = CMA::CharacterizationService.characterize(content)
        characterization.ng_xml = metadata if metadata.present?
        append_metadata
        self.filename = [content.original_name]
        save
      end
    end
  end
end