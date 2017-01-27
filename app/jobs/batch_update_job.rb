require 'csv'

class BatchUpdateJob < ActiveJob::Base
	attr_accessor :batch_file 

	queue_as :batch_update

    def perform(path_to_csv)
      self.batch_file = path_to_csv
	  @root_directory = File.dirname(File.expand_path(self.batch_file))
 
	  if !File.exists?(batch_file) then
		Rails.logger.info "[#{log_prefix}] Warning: unable to locate a manifest file"
		raise CMA::Exceptions::FileNotFoundError.new "Could not resolve #{batch_file} to a valid path"  
	  end

	  process_batch
    end
	
	# Read in the CSV file which should follow the following format
	#
	# [title]
    # [creator]
	# [creation date]
	# [parent collection]
	# [blank line]
	# [file, tag, tag, ...]
	# [01.tif, nrogers@clevelandart.org, ...]  
    def process_batch
  	  metadata = CSV.read(@batch_file)
      collection_title = metadata.shift.first.titleize
	  @collection = find_collection(collection_title)

      # Skip to the file manifest
      metadata.shift(4)
	  process_files(metadata)
    end

	def process_files(metadata)
      # We need to remember the list of metadata fields for later. Ignore
      # only the mandatory :file attribute
      fields = metadata.shift
      fields.map! { |field| field.to_sym }.delete(:file)
     
      metadata.each do |resource|
        filename = resource.shift
        path = "file://#{@root_directory}/#{filename}"
        id_to_update = @collection.find_children_by(import_url: path)

        if id_to_update.present?
          gf = GenericFile.find id_to_update.first
          Rails.logger.info "[#{log_prefix}] Updating #{gf.id} (#{filename})"
          gf = apply_metadata_properties(gf, fields, resource)
	      gf.save
	    else
          Rails.logger.info "[#{log_prefix}] Could not find #{filename}"
        end
      end
	end

	# Iterate over all the collections found looking for an exact match.
	# There may be a better way of doing this but it will at least get the 
	# process bootstrapped until time permits an incremental improvement
    def find_collection(title)
      collection_id = ActiveFedora::SolrService.query("primary_title_ssi:\"#{title}\"", {fq: "has_model_ssim:Collection", fl: "id"})

      (collection_id.count > 0) ? Collection.find(collection_id.first["id"]) : nil
    end

    # Apply default metadata at the time of creation. 
    #
    # gf: Generic File object
    # values: Array of values
    # fields: Mappings to metadata fields
    def apply_metadata_properties(resource, fields, values)
      values.each_with_index do |val, i|
        if val.blank?
          Rails.logger.warn "[#{log_prefix}] Ignoring empty field #{fields[i]}"
          next
        end

        field = fields[i]

        # When multivalued save as an array
        if resource[field].is_a? Array
          resource[field] += val.split("|")
          resource[field].uniq!
        else
          resource[field] = v
        end
      end

      resource
    end

    def log_prefix
      "BATCH UPDATE"
    end
end

