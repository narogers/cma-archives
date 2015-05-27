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
		if !File.exists?(batch_file)
			puts '[BATCH INGEST] Warning: unable to locate a manifest file'
			return
		end

		root_directory = File.dirname(File.expand_path(batch_file))
		File.open("#{root_directory}/.processing", "w") do |f|
			f.write Time.now
		end

		# Create two file streams - one for files that completed and
		# one for failed files. Also open a new Logger instance that
		# will record all activity since it is now done synchronously
		success_log = File.open("#{root_directory}/processed_files.log", 'w')
		failure_log = File.open("#{root_directory}/failed_files.log", 'w')
		activity_log = Logger.new("#{root_directory}/activity.log")

		# Read in the CSV file which should follow the following format
		#
		# [title]
		# [creator]
		# [collection|collection|collection]
		# [blank line]
		# [file, tag, tag, ...]
		# [01.tif, nrogers@clevelandart.org, ...]
		metadata = CSV.read(batch_file, skip_blanks: true)
	  batch = Batch.new

	  batch.title = metadata.shift
	  batch.creator = metadata.shift
	  # Verify that the creator exists or default to the system's
	  # batch account
	  if (0 == User.where(email: batch.creator).count)
	    batch.creator = [User.batchuser.email]
	  end
	  batch.save

	  # For use in helper methods save this NOT as an array but as a string
	  self.batch_creator = batch.creator.first

	  # You actually get an array back so before splitting you have to extract the
	  # first string as this should be the only value in the row
	  collection_names = metadata.shift.first.split("|")
	  # Add the batch title as a collection as well
	  collection_names << batch.title.first
	  collections = []
	  collection_names.each do |coll|
	  	collection = findCollection(coll)
	  	if collection.nil?
	  		collection = createCollection(coll)
	  	end
	  	
	  	activity_log.info "[BATCH] Adding resources to existing collection #{coll}"
	  	collections << collection
	  end

	  # Shift off the row of headers so you don't try to process
	  # "file"
	  metadata.shift

	  # The rest of the file should be a list of files and associated
	  # properties
    metadata.each do |resource|
	  	gf = GenericFile.new
	  	gf.import_url = "file://#{root_directory}/#{resource[0]}"
	  	gf = applyDefaultAccessControls(gf)
	  	gf.collections = collections
	  	gf.save
	  	
	  	# Kick off the processing step synchronously so that the batch
	  	# as a whole will fail at the first bad file. It also makes
	  	# it easier to do logging
	  	begin
	  		activity_log.info "[IMPORT] Attempting to ingest #{resource[0]}"
	  	  ImportUrlJob.new(gf.id)
	  		success_log << resource[0]
	  		success_log << "\r\n"
	  	rescue => err
	  		failure_log << resource[0]
	  		failure_log << "\r\n"
	  		activity_log.warn("[IMPORT] A problem occurred processing #{resource[0]}")
	  		activity_log.warn(err)
	  	end
	  end

	  # Close the log files at the end of the process
	  success_log.close
	  failure_log.close
	  FileUtils.rm("#{root_directory}/.processing")
	end

	def createCollection(title)
		puts "[BATCH] Creating a new collection - #{title}"

		collection = Collection.new
		collection.title = title
		collection = applyDefaultAccessControls(collection)
		collection.save

		return collection
	end

	# Iterate over all the collections found looking for an exact match.
	# There may be a better way of doing this but it will at least get the 
	# process bootstrapped until time permits an incremental improvement
	def findCollection(title)
		collections = Collection.where(["title_tesim: \"#{title}\""])
		collections.each do |c|
			return c if c.title.eql?(title)
		end

		# If we fall through to here then hang your head in shame and return
		# nil
		return nil
	end

	# Define some default access permissions to the collection
	# that will make it globally accessible to anyone who is
	# registered. This works because the next iteration will use the
	# role map to permit access collection by collection
	def applyDefaultAccessControls(resource)
		resource.depositor = batch_creator
		resource.edit_users = [batch_creator]
		resource.edit_groups = [:admin]
		resource.read_groups = [:patron, :archivist]

		return resource
	end
end
