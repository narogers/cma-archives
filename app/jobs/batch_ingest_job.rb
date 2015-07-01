require 'csv'

class BatchIngestJob < ActiveFedoraIdBasedJob
	attr_accessor :batch_file, :batch_creator

	def queue_name
		:batch_ingest
	end

	def initialize(batch_metadata)
		self.batch_file = batch_metadata
	end
	
	def run
		if !File.exists?(batch_file) then
			Resque.logger.info '[BATCH INGEST] Warning: unable to locate a manifest file'
			return
		end

	  generate_log_files
		process_batch
		close_log_files
  end

  def generate_log_files
		@root_directory = File.dirname(File.expand_path(self.batch_file))
		FileUtils.touch("#{@root_directory}/.processing")

		# Create two file streams - one for files that completed and
		# one for failed files. Also open a new Logger instance that
		# will record all activity since it is now done synchronously
		@success_log = File.open("#{@root_directory}/processed_files.log", 'w')
		@failure_log = File.open("#{@root_directory}/failed_files.log", 'w')
		@activity_log = Logger.new("#{@root_directory}/activity.log")
  end

	# Read in the CSV file which should follow the following format
	#
	# [title]
  # [creator]
	# [collection|collection|collection]
	# [blank line]
	# [file, tag, tag, ...]
	# [01.tif, nrogers@clevelandart.org, ...]  def load_metadata
  def process_batch
  	@metadata = CSV.read(batch_file)

	  # TODO: Sanity check for missing fields
	  @batch = Batch.new(
	  	title: @metadata.shift,
	  	creator: @metadata.shift)

	  # Verify that the creator exists or default to the system's
	  # batch account
	  if (0 == User.where(login: @batch.creator).count)
	    @batch.creator = [User.batchuser.login]
	  end
	  @batch.save
	  self.batch_creator = @batch.creator.first

	  collections = process_collections
	  process_files(collections)
	end

 	def process_collections
	  # Each line should be a collection title until you reach a
	  # blank line at which point the list is assumed to be complete.
	  # This means that additional collection membership is optional.
	  collection_name = @metadata.shift
	  collection_names = []

	  # Because it is a CSV file the line comes across as an array
	  # rather than a string
	  while collection_name.present? do
	    collection_names << collection_name.first unless collection_name.empty?
	  	collection_name = @metadata.shift
	  end

	  # As a default add the batch name as a collection
	  collection_names << @batch.title.first
	  collections = []
	  collection_names.each do |coll|
	  	collection = find_or_create_collection(coll)
	  	
	  	@activity_log.info "[BATCH] Adding resources to existing collection #{coll}"
	  	collections << collection
	  end

	  collections
	end

	def process_files(collections = [])
	  # Shift off the row of headers so you don't try to process
	  # "file" header
	  @metadata.shift
	  # The rest of the file should be a list of files and associated
	  # properties
    @metadata.each do |resource|
	  	gf = GenericFile.new(
	  			import_url: "file://#{@root_directory}/#{resource[0]}",
	  		  collections: collections,
	  		  )
	  	gf = apply_default_acls(gf)
	  	gf.save
	 	
	 	  # Kick off the processing step synchronously so that the batch
	 	  # as a whole will fail at the first bad file. It also makes
	 	  # it easier to do logging
	  	begin
	  		@activity_log.info "[IMPORT] Attempting to ingest #{resource[0]}"
	  	  ImportUrlJob.new(gf.id).run
	  		@success_log << "#{resource[0]}\r\n"
	 	  rescue => err
	  		@failure_log << "#{resource[0]}\r\n"
	  		@activity_log.error("[IMPORT] A problem occurred processing #{resource[0]}")
	  		@activity_log.error(err)
	  	end
	  end
	end

	def close_log_files
	  @success_log.close
	  @failure_log.close
	  FileUtils.rm("#{@root_directory}/.processing")
	end

	def create_collection(title)
		Resque.logger.info "[BATCH] Creating a new collection - #{title}"
		collection = Collection.new(title: title)
		collection = apply_default_acls(collection)
		collection.save

		collection
	end

	# Iterate over all the collections found looking for an exact match.
	# There may be a better way of doing this but it will at least get the 
	# process bootstrapped until time permits an incremental improvement
	def find_or_create_collection(title)
		collections = Collection.where(["title_tesim: \"#{title}\""])
		collections.each do |c|
			return c if c.title.eql?(title)
		end

		# Only now do we create a new collection object
		create_collection(title)
	end

	# Define some default access permissions to the collection
	# that will make it globally accessible to anyone who is
	# registered. This works because the next iteration will use the
	# role map to permit access collection by collection
	def apply_default_acls(resource)
		resource.depositor = self.batch_creator
		resource.edit_users = [self.batch_creator]
		# Group defaults
		resource.edit_groups = [:admin]
		resource.discover_groups = [:admin]
		resource.read_groups = [:admin]

		resource
	end
end