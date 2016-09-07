# Just need to override the characterize method to make a call to the FITS
# servlet instead of invoking FITS on the command line. This should be a one
# line change to https://github.com/projecthydra/sufia/blob/6.x-stable/sufia-models/app/models/concerns/sufia/generic_file/characterization.rb#L71-L78
module CMA
  module GenericFile
    module Characterization
      def characterize
        Rails.logger.info "[CHARACTERIZE] Processing #{self.id}"
        # TODO: Remove hard coded arbitrary limit
        metadata = (content.size < (200 * 2**30)) ?
          CMA::CharacterizationService.characterize(content) :
          content.extract_metadata
        characterization.ng_xml = metadata if metadata.present?
        append_metadata
        self.filename = [content.original_name]
        save
      end
    end
  end
end
