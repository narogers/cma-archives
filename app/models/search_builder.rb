class SearchBuilder < Hydra::SearchBuilder
  include Hydra::PolicyAwareAccessControlsEnforcement
  include Sufia::SearchBuilder
  
  # TODO: Short term patch for logging
  def logger
    Rails.logger
  end
end
