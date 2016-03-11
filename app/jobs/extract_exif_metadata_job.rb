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
    Resque.logger.info "[EXIF] Extracting EXIF headers for #{generic_file.id}"
    return unless generic_file.content.has_content?
    return unless generic_file.image?

    # Now with those out of the way we can get down to the business
    # of metadata extraction. This is mostly cribbed directly from
    # the way that the characterization is done for FITS
    #
    # TODO: Make this work with local files
    generic_file.content.local_path = generic_file.import_url.sub("file://", "")
    Hydra::Derivatives::TempfileService.create(generic_file.content) do |f|
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
            #
            # Also strip out any pipes, such as in the :subject
            # field and replace them with more readable -- dividers
            if (metadata.is_a? Array)
              metadata.map! { |meta| meta.to_s.gsub("|", " -- ") } 
            else
               metadata = metadata.to_s.gsub("|", " -- ")
            end

    		# Here we know that the tag exists and just needs to
    		# be mapped accordingly. We need to determine if it is
    		# multivalued and push an array instead of a scalar value
    		# to prevent errors.
    		Resque.logger.info '[EXIF] Processing ' + field.to_s

    		if (generic_file[field].is_a? Array)
              if metadata.is_a? Array
                generic_file[field] += metadata
              else
                generic_file[field] += [metadata]
              end
              # Call uniq! since a bug in ActiveFedora prevents usage of the handy
              # << method
              generic_file[field].uniq!
    		else
    		  generic_file[field] = (metadata.is_a? Array) ? metadata.join(" ") : metadata
    		end
    	end

        # A couple of fields get default values if nothing was set 
        # from the image itself
        if generic_file[:rights].nil?
            generic_file[:rights] = "Copyright, The Cleveland Museum of Art"
        end

        generic_file[:contributor] += ["Cleveland Museum of Art"]
        generic_file[:contributor].uniq!

        generic_file[:language] += ["en"]
        generic_file[:language].uniq!		

		# If there is a little housekeeping to do for some key 
		# fields it should happen here as needed    	
		generic_file.save
    end
  end
end
