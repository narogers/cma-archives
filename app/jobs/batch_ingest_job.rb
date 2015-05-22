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
	  	
	  	puts "[BATCH] Adding resources to existing collection #{coll}"
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
	  	
	  	# Kick off the processing step in the background
	  	Sufia.queue.push(ImportUrlJob.new(gf.id))

	  end

	FileUtils.mv("#{root_directory}/.processing",
		     "#{root_directory}/processed")
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
