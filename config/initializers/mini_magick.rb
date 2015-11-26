require 'mini_magick'

# Switch the default image handling library from ImageMagick to
# GraphicsMagick and explicitly set the path
MiniMagick.configure do |config|
  config.cli = :graphicsmagick
    config.cli_path = "/usr/bin"
    # Patch from upstream Sufia
    config.shell_api = "posix-spawn"
end
