class SearchBuilder < Hydra::SearchBuilder
  include Hydra::PolicyAwareAccessControlsEnforcement
  include Sufia::SearchBuilder
  
  # Applies access controls to all Solr queries
  self.default_processor_chain += [:add_access_controls_to_solr_params, :add_advanced_parse_q_to_solr]  

  # TODO: Short term patch for logging
  def logger
    Rails.logger
  end
end
