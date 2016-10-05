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
    Rails.logger.info "[EXIF] Extracting EXIF headers for #{generic_file.id}"
    return unless generic_file.content.has_content?
    return unless generic_file.image?

    Hydra::Derivatives::TempfileService.create(generic_file.content) do |f|
   	  exifdata = MiniExiftool.new(f.path)
      Sufia.config.exif_to_desc_mapping.each_pair do |exif_node, field|
        next if exifdata[exif_node].blank?

        metadata = normalize(exifdata[exif_node])
        Rails.logger.info '[EXIF] Processing ' + field.to_s

    	if (generic_file[field].is_a? Array)
          if metadata.is_a? Array
            generic_file[field] += metadata
          else
            generic_file[field] += [metadata]
          end
        else
          generic_file[field] = 
                (metadata.is_a? Array) ? metadata.join(" ") : metadata
    	end
      end

      default_fields
      generic_file.save
    end
  end

  def default_fields
    if generic_file[:rights].blank?
      generic_file[:rights] = ["Copyright, The Cleveland Museum of Art"]
    end

    generic_file[:contributor] += ["Cleveland Museum of Art"]
    generic_file[:contributor].uniq!

    generic_file[:language] += ["en"]
    generic_file[:language].uniq!		

    # TODO: Actually set this dynamically based on MIME type instead of
    #       being hard coded
    generic_file[:resource_type] += ["Image"]
    generic_file[:resource_type].uniq!

    generic_file
  end
    
  # Normalize the field values
  def normalize value
    if value.is_a? Array
      value.map! { | meta| normalize(meta) }
      return value
    end

    value = value.to_s.gsub("|", "--")
    value.gsub!(/[[:cntrl:]]/, "")

    value
  end
end
