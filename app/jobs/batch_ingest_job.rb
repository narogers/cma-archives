require 'csv'

class BatchIngestJob < ActiveFedoraIdBasedJob
  include Sufia::Lockable

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
      @created_on = metadata.shift.first
      @administrative_collection = metadata.shift.first

      set_creation_date(@created_on)
      add_collection_relationships(@administrative_collection)

      # Ignore the blank line
      metadata.shift.first
	  process_files(metadata, batch)
    end

    def set_creation_date(date)
      @collection.date_created = [date]
      @collection.save
    end

    # TODO: Mark as deprecated
 	def add_collection_relationships(administrative_collection)
      title = administrative_collection.titleize
      admin_coll = find_collection(title)
      if admin_coll.nil?
        Rails.logger.warn("[#{log_prefix}] Could not locate #{title}")
      else
        @collection.collections = [admin_coll]
        @collection.save
      end
	end

	def process_files(metadata, batch)
      # We need to remember the list of metadata fields for later. Ignore
      # only the mandatory :file attribute
      fields = metadata.shift
      fields.map! { |field| field.to_sym }.delete(:file)
     
	  # The rest of the file should be a list of files and associated
	  # properties
      resources = []

      metadata.each do |resource|
        filename = resource.shift
        expanded_file_uri = "file://#{@root_directory}/#{filename}"
  
        # TODO: Modify search to be unique across entire repository not just
        #       scoped to a collection
        current_children_ids = @collection.find_children_by(import_url: expanded_file_uri)

        if current_children_ids.empty?
	      gf = GenericFile.create(
            import_url: expanded_file_uri,
            label: filename,
            batch: batch,
            depositor: @collection.depositor
	      )

          Rails.logger.info "[#{log_prefix}] Ingesting #{gf.id} (#{filename})"
	    else
          gf = GenericFile.find current_children_ids.first
          fixity = Fixity.new(gf.id)
          if fixity.equal?
            Rails.logger.info "[#{log_prefix}] Skipping #{gf.id} (#{filename})"
            next
          else
            Rails.logger.info "[#{log_prefix}] Updating #{gf.id} (#{filename})"
          end
        end

        apply_metadata_properties(gf, fields, resource).save
        gf.reload
        resources << gf
      end

      admin_coll = find_administrative_collection(@administrative_collection)
      acquire_lock_for(@collection.id) do
        @collection.administrative_collection = admin_coll
        unless resources.empty?
          @collection.members += resources
        end
        @collection.save
      end

      resources.each do |gf|
        gf.administrative_collection = admin_coll
        gf.save
        Sufia.queue.push(IngestLocalFileJob.new(gf.id))
      end
	end

	def create_collection(title, creator)
		Rails.logger.info "[#{log_prefix}] Creating a new collection - #{title}"
		Collection.create(title: title,
          depositor: creator,
          edit_users: [creator],
          resource_type: ["Collection"])
	end

    def find_collection(title)
      collection_id = ActiveFedora::SolrService.query("primary_title_ssi:\"#{title}\"", {fq: "has_model_ssim:Collection", fl: "id"})

      (collection_id.count > 0) ? Collection.find(collection_id.first["id"]) : nil
    end

    def find_administrative_collection(title)
      field = ActiveFedora::SolrQueryBuilder.solr_name("title")
      policy_id = ActiveFedora::SolrService.query("#{field}:\"#{title}\"", {fq: "has_model_ssim:AdministrativeCollection", fl: "id", rows: 1})

      if policy_id.empty?
        Rails.logger.warn "[#{log_prefix}] Administrative collection '#{title}' could not be found"
        Rails.logger.warn "[#{log_prefix}] Run bin/rake cma:install and try again"
        nil
      else
        policy_id = policy_id.first["id"]
        AdministrativeCollection.find(policy_id)
      end
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

