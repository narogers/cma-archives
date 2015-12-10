require 'hydra/derivatives' unless defined? Hydra::Derivatives

# Overrides for Hydra Derivatives 
#
# Use a custom source service that first looks on local disk before trying
# to query Fedora
Hydra::Derivatives.config.source_file_service = LocalSourceFileService
