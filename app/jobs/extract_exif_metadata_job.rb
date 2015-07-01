# Run this job on images to pull out any metadata which will be
# mapped to the descriptive metadata fields based on the settings
# in exiftool_to_desc_mappings in config/initializers/sufia.rb
#
# If this is not set, or the content is not recognized as an image,
# then nothing exciting will happen
class ExtractExifMetadataJob < ActiveFedoraIdBasedJob
  def queue_name
    return :exif_metadata
  end
  
  def run
    # Set two escape clauses before you go any further
    return unless generic_file.content.has_content?
    return unless generic_file.image?

    # Now with those out of the way we can get down to the business
    # of metadata extraction. This is mostly cribbed directly from
    # the way that the characterization is done for FITS
    Hydra::Derivatives::TempfileService.create(generic_file.content) do |f|
        Resque.logger.info "[EXIFTOOL] Using temporary file #{f.path}"
    	exifdata = MiniExiftool.new(f.path)
    	Sufia.config.exif_to_desc_mapping.each_pair do |exif_node, field|
    		# A missing tag returns nil - let's use that to our
    		# advantage when populating the metadata attributes
    		next if exifdata[exif_node].blank?

            # We need to change a local copy *NOT* modify the original
            # image since that will have no impact
            metadata = exifdata[exif_node]

            # Clean up the data to cast everything in the
            # array to text even if it is a date, integer,
            # or some other value
            if (metadata.is_a? Array)
              metadata.map! { |meta| meta.to_s}
            else
               metadata = metadata.to_s
            end

    		# Here we know that the tag exists and just needs to
    		# be mapped accordingly. We need to determine if it is
    		# multivalued and push an array instead of a scalar value
    		# to prevent errors.
    		Resque.logger.info '[EXIF] Processing ' + field.to_s
    		if (generic_file[field].is_a? Array)
    		  generic_file[field] = (metadata.is_a? Array) ? metadata : [metadata]
    		else
    		  generic_file[field] = (metadata.is_a? Array) ? metadata.join(" ") : metadata
    		end
    	end

        # A couple of fields get default values if nothing was set 
        # from the image itself
        if generic_file[:rights].nil?
            generic_file[:rights] = "Copyright, Cleveland Museum of Art"
        end
        
		# If there is a little housekeeping to do for some key 
		# fields it should happen here as needed    	
		generic_file.save
    end
  end
end
