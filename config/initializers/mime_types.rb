# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
Mime::Type.register 'application/x-endnote-refer', :endnote

# Register a new MIME Type for Digital Negatives (DNG) with the
# MIME::Type gem
dngs = MIME::Type.new('image/x-adobe-dng')
dngs.extensions = 'dng'
MIME::Types.add(dngs)
