# Run this job on images to pull out any metadata which will be
# mapped to the descriptive metadata fields based on the settings
# in exiftool_to_desc_mappings in config/initializers/sufia.rb
#
# If this is not set, or the content is not recognized as an image,
# then nothing exciting will happen
class ExtractExifMetadataJob < ActiveFedoraIdBasedJob
  def run
    # Set two escape clauses before you go any further
    return unless generic_file.content.has_content?
    return unless generic_file.image?

    # Now with those out of the way we can get down to the business
    # of metadata extraction. This is mostly cribbed directly from
    # the way that the characterization is done for FITS
    generic_file.content.to_tempfile do |f|
    	exifdata = MiniExiftool.new(f.path)
    	Sufia.config.exif_to_desc_mapping.each_pair do |k, v|
    		# A missing tag returns nil - let's use that to our
    		# advantage when populating the metadata attributes
    		next if exifdata[k].blank?

    		# Here we know that the tag exists and just needs to
    		# be mapped accordingly. We need to determine if it is
    		# multivalued and push an array instead of a scalar value
    		# to prevent errors.
    		puts '[EXIF] Processing ' + v.to_s
    		pp exifdata[k]

    		if (generic_file[v].is_a? Array)
    		  generic_file[v] = (exifdata[k].is_a? Array) ? exifdata[k] : [exifdata[k]]
    		else
    		  generic_file[v] = (exifdata[k].is_a? Array) ? exifdata[k].join(" ") : exifdata[k]
    		end
    		pp generic_file[v]
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
