require 'mini_magick'

# Switch the default image handling library from ImageMagick to
# GraphicsMagick and explicitly set the path
MiniMagick.configure do |config|
  config.cli = :imagemagick
  config.cli_path = "/usr/local/bin"
  # Patch from upstream Sufia
  config.shell_api = "posix-spawn"
  config.whiny = false
end
