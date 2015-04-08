class BatchIngestJob
	attr :collection
	attr :base_directory

	def queue_name
		:batch_ingest
	end

	def run
		if base_directory.blank?
			puts '[BATCH INGEST] Warning: unable to proceed with no base directory. Please provide a root path and try again'
			return
		end

		# TODO: Put in some safeguards to prevent looking at the wrong
		#       directories
		#
		# TODO : Make batches configurable along with
		#        defining shorcuts for groups and users tied to a
		#        key such as :editorial, :object, etc
		#
		# Expand the path and then grab all files - the filtering will
		# take place just before it gets send to ImportUrlJob. **/* is
		# a glob that will ignore just directories
		root_path = FIle.expand_path(base_directory)
		Dir.foreach([root_path, "**/*"].join("/") do |f|
			mime_type = MIME::Types.of(f).first
			next if mime_type.blank?

			# For now just process images and skip other formats like PDF
			# or video
			if ("image" == mime_type.media_type)
				ingestLocalFile(f)
			end
		end
	end

	protected
	def ingestLocalFile(f)
		generic_file = GenericFile.new
		generic_file.import_url = "file://" + f

		generic_file.depositor = 'syslib@clevelandart.org'
		generic_file.edit_users = ['syslib@clevelandart.org']
		generic_file.collection = [collection] unless collection.blank?
		generic_file.save
		Sufia.queue.push(IngestLocalCMAFileJob.new(generic_file.id))
	end
end