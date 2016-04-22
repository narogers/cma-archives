require 'csv'

class BatchIngestJob < ActiveFedoraIdBasedJob
	attr_accessor :batch_file

	def queue_name
		:batch_ingest
	end

	def initialize(batch_metadata)
		self.batch_file = batch_metadata
		@root_directory = File.dirname(File.expand_path(batch_metadata))
	end
	
    def run
	  if !File.exists?(batch_file) then
		Rails.logger.info '[BATCH] Warning: unable to locate a manifest file'
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
  	  metadata = CSV.read(batch_file)

	  @batch = Batch.new(
	    title: [metadata.shift.first.titleize],
	    creator: [metadata.shift.first])
   
	  # Verify that the creator exists or default to the system's
	  # batch account
	  if (0 == User.where(login: @batch.creator.first).count)
	    @batch.creator = [User.batchuser.login]
	  end
	  @batch.save

	  @collection = find_or_create_collection(@batch.title.first)
      set_creation_date(metadata.shift.first)
      add_collection_relationships(metadata.shift.first)
      # Ignore the blank line
      metadata.shift.first
	  process_files(metadata)
    end

    def set_creation_date(date)
      @collection.date_created = [date]
    end

 	def add_collection_relationships(parent_title)
	  # Each line should be a collection title until you reach a
	  # blank line at which point the list is assumed to be complete.
	  # This means that additional collection membership is optional.

	  # Because it is a CSV file the line comes across as an array
	  # rather than a string
      parent_title = parent_title.titleize
      parent_collection = find_collection(parent_title)
      if parent_collection.nil?
        Rails.logger.warn("[BATCH] Could not locate #{parent_title}")
      else
        @collection.collection_ids += [parent_collection.id]
      end
      @collection.save
	end

	def process_files(metadata)
      # We need to remember the list of metadata fields for later. Ignore
      # only the mandatory :file attribute
      fields = metadata.shift
      fields.map! { |field| field.to_sym }.delete(:file)
      
	  # The rest of the file should be a list of files and associated
	  # properties
      metadata.each do |resource|
        filename = resource.shift
        unless @collection.contains?(label: filename)
	      gf = GenericFile.new(
            import_url: "file://#{@root_directory}/#{filename}",
	        collection_ids: [@collection.id],
            label: filename
	      )
          gf = apply_metadata_properties(gf, fields, resource)
	      gf = apply_default_acls(gf)
	      gf.save
	 	
          Rails.logger.info "[BATCH] Ingesting #{gf.id} (#{filename}) into #{@batch.title.first}"
	      Sufia.queue.push(ImportUrlJob.new(gf.id))
	    else
          Rails.logger.info "[BATCH] Skipping existing file #{filename}" 
        end
      end
	end

	def create_collection(title)
		Rails.logger.info "[BATCH] Creating a new collection - #{title}"
		collection = Collection.new(title: title)
		collection = apply_default_acls(collection)
		collection.save

		collection
	end

	# Iterate over all the collections found looking for an exact match.
	# There may be a better way of doing this but it will at least get the 
	# process bootstrapped until time permits an incremental improvement
    def find_collection(title)
      collections = Collection.where(["title_tesim: \"#{title}\""])
	  collections.each do |c|
		return c if c.title.eql?(title)
	  end

      # In case of emergency break glass and return nil
      nil
    end

    def find_or_create_collection(title)
        collection = find_collection(title)
		# Only if there was no result do we try again
		collection = create_collection(title) if collection.nil?
        # And now return the result
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
          Rails.logger.warn "[BATCH] Could not process empty field #{fields[i]}"
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

	# Define some default access permissions to the collection
	# that will make it globally accessible to anyone who is
	# registered. This works because the next iteration will use the
	# role map to permit access collection by collection
	def apply_default_acls(resource)
		resource.depositor = @batch.creator.first
		resource.edit_users = @batch.creator
		# Group defaults
		resource.edit_groups = [:admin]
		resource.discover_groups = [:admin]
		resource.read_groups = [:admin]

		resource
	end
end
