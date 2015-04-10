require 'csv'

class BatchIngestJob
	attr :collection
	attr :batch_file

	def queue_name
		:batch_ingest
	end

	def run
		if !File.exists?(batch_file)
			puts '[BATCH INGEST] Warning: unable to locate a manifest file'
			return
		end

		root_directory = File.dirname(File.expand_path(batch_file))
		
		# Read in the CSV file which should follow the following format
		#
		# [title]
		# [creator]
		# [blank line]
		# [file, collections, tag, tag, ...]
		# [01.tif, "Collection", nrogers@clevelandart.org, ...]
		metadata = CSV.read(batch_file, {skip_blank: true})
	  batch = Batch.new
	  batch.title =  metadata.shift
	  batch.creator = metadata.shift
	  batch.save

	  # Drop the first column which is the file name
	  headers = metadata.shift
	  headers.shift
	  # The rest of the file should be a list of files and associated
	  # properties
	  metadata.each do |image|
	  	# TODO: Pick up here Monday with helper methods to create a
	  	#       generic file, tie it to collections, and then kick off
	  	#       an importURL job
	  	gf = create_generic_file(image)
	  	gf = GenericFile.new
	  	gf.import_url = "file://#{root_directory}/#{image[0]}"
	  	gf.depositor = batch.creator
	  	gf.edit_users = [batch.creator]
	  	update_collections(gf, )
	  	gf.save


	  end
	end

end