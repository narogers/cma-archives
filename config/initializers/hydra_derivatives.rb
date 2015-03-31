require 'mini_magick'

# Switch the default image handling library from ImageMagic to
# GrahicsMagick and explicitly set the path
MiniMagick.configure do |config|
  config.cli = :graphicsmagick
  config.cli_path = "/usr/bin"
end