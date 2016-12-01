require 'csv'

class BatchIngestJob < ActiveFedoraIdBasedJob
	attr_accessor :batch_file 

    # :nocov:
	def queue_name
		:batch_ingest
	end
    # :nocov:

	def initialize(csv_path, batch_id = nil)
		self.batch_file = csv_path
        @batch_id = batch_id
	end
	
    def run
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
      batch = find_batch(@batch_id)
  	  metadata = CSV.read(@batch_file)
  
      collection_title = metadata.shift.first.titleize
	  creator = metadata.shift.first
	  if (0 == User.where(login: creator).count)
	    creator = User.batchuser.login
	  end

	  @collection = find_or_create_collection(collection_title, creator)
      set_creation_date(metadata.shift.first)
      add_collection_relationships(metadata.shift.first)
      @collection = apply_default_acls(@collection)
      @collection.save

      # Ignore the blank line
      metadata.shift.first
	  process_files(metadata, batch)
    end

    def set_creation_date(date)
      @collection.date_created = [date]
    end

 	def add_collection_relationships(parent_title)
      parent_title = parent_title.titleize
      parent_collection = find_collection(parent_title)
      if parent_collection.nil?
        Rails.logger.warn("[#{log_prefix}] Could not locate #{parent_title}")
      else
        @collection.collections += [parent_collection]
      end
	end

	def process_files(metadata, batch)
      # We need to remember the list of metadata fields for later. Ignore
      # only the mandatory :file attribute
      fields = metadata.shift
      fields.map! { |field| field.to_sym }.delete(:file)
      
	  # The rest of the file should be a list of files and associated
	  # properties
      resources_to_import = []

      metadata.each do |resource|
        filename = resource.shift
        expanded_file_uri = "file://#{@root_directory}/#{filename}"

        current_children_ids = @collection.find_children_by(import_url: expanded_file_uri)

        if current_children_ids.empty?
	      gf = GenericFile.create(
            import_url: expanded_file_uri,
            label: filename,
            batch: batch,
            edit_users: @collection.edit_users,
            depositor: @collection.depositor
	      )
          gf = apply_metadata_properties(gf, fields, resource)
	      gf = apply_default_acls(gf)
          gf.save

          @collection.member_ids += [gf.id]
          gf.collection_ids = [@collection.id]
 
          Rails.logger.info "[#{log_prefix}] Ingesting #{gf.id} (#{filename})"
          resources_to_import << gf.id
	    else
          gf_id = current_children_ids.first
          fixity = Fixity.new(gf_id)
          unless fixity.equal?
            Rails.logger.info "[#{log_prefix}] Updating #{gf_id} (#{filename})"
            resources_to_import << gf_id
          else
            Rails.logger.info "[#{log_prefix}] Skipping #{gf_id} (#{filename})"

          end
        end
      end

      resources_to_import.each do |gf_id|
        Sufia.queue.push(ImportUrlJob.new(gf_id))
      end
	end

	def create_collection(title, creator)
		Rails.logger.info "[#{log_prefix}] Creating a new collection - #{title}"
		collection = Collection.create(title: title,
          depositor: creator,
          edit_users: [creator],
          resource_type: ["Collection"])

		collection
	end

	# Iterate over all the collections found looking for an exact match.
	# There may be a better way of doing this but it will at least get the 
	# process bootstrapped until time permits an incremental improvement
    def find_collection(title)
      collection_id = ActiveFedora::SolrService.query("primary_title_ssi:\"#{title}\"", {fq: "has_model_ssim:Collection", fl: "id"})

      (collection_id.count > 0) ? Collection.find(collection_id.first["id"]) : nil
    end

    def find_or_create_collection(title, creator)
        collection = find_collection(title)
		collection = create_collection(title, creator) if collection.nil?

        collection
    end

    # Apply default metadata at the time of creation. 
    #
    # gf: Generic File object
    # values: Array of values
    # fields: Mappings to metadata fields
    def apply_metadata_properties(resource, fields, values)
      values.each_with_index do |value, i|
        if value.blank?
          Rails.logger.warn "[#{log_prefix}] Could not process empty field #{fields[i]}"
          next
        end

        field = fields[i]
        # When multivalued save as an array
        if resource[field].is_a? Array
          resource[field] = [value]
        else
          resource[field] = value
        end
      end

      resource
    end

	def apply_default_acls(resource)
        resource.edit_users += ["admin"]
		resource.edit_groups += [:admin]
  
        unless resource.collections.empty?
          resource.collections.each do |c|
            resource.edit_users += c.edit_users
            resource.edit_groups += c.edit_groups
            resource.discover_groups += c.discover_groups
            resource.read_groups += c.read_groups
          end
        end

		resource
	end

    # Attempt to load the batch which all resources should belong to.
    # If not found fall back to nil and proceed without the resources
    # being associated to any grouping
    def find_batch(id)
      begin
        id.blank? ? nil : ::Batch.find(id) 
      rescue ActiveFedora::ObjectNotFoundError
        nil
      end  
    end

    def log_prefix
      @batch_id.present? ?
        "BATCH #{@batch_id}" :
        "BATCH"
    end
end

