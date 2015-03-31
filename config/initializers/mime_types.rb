# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
Mime::Type.register 'application/x-endnote-refer', :endnote

# Register a new MIME Type for Digital Negatives (DNG) with the
# MIME::Type gem
dngs = MIME::Type.new('image/x-adobe-dng')
dngs.extensions = 'dng'
MIME::Types.add(dngs)

# Finally make a quick monkey patch to ActiveFedora::Base that
# fixes the MIME types for DNG files to deal with the fact that
# when uploaded jQuery file uploader sets the type to
# 'application/octet-stream', that FITS sometimes sets it to
# 'image/tiff', and other leaks
module ActiveFedora
	module AttachedFiles
		alias_method :old_add_file, :add_file

		def add_file(file, *args)
			old_add_file(file, *args)
			# Copy this chunk of code from the existing method to
			# set up opts properly
			opts = if args.size == 1
              args.first
             else
               { path: args[0], original_name: args[1], mime_type: args[2] }
            end

			# Now adjust the MIME type even if has already been set
			# by checking the file name against the MIME Type
			# database
			puts '[ADD FILE] Adjusting the MIME type for ' + opts[:original_name]
			new_mime_type = MIME::Types.of(opts[:original_name])
			new_mime_type = new_mime_type.empty? ? 'application/octet-stream' : new_mime_type.first.content_type
			puts '[ADD FILE] MIME Type will be set to ' + new_mime_type
			self[opts[:path]].mime_type = new_mime_type
		end
	end
end

