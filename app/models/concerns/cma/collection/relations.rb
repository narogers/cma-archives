module CMA
  module Collection
    module Relations
      extend ActiveSupport::Concern
      included do
        has_and_belongs_to_many :subcollections, 
          predicate: ActiveFedora::RDF::Fcrepo::RelsExt.hasPart,
          class_name: "ActiveFedora::Base"
      end
    end
  end
end
