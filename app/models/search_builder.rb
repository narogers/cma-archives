# frozen_string_literal: true
class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include Hydra::AccessControlsEnforcement
  
  self.default_processor_chain += [:add_access_controls_to_solr_params,
    :add_advanced_parse_q_to_solr]
end
