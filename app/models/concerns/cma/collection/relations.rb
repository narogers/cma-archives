# Adds similar functionality for collections that exists in GenericFiles
# and their children. Specifically this acts as a stopgap until a migration
# to PCDM which fully supports the notion of subcollections without any
# extra work
module CMA
  module Collection
    module Relations
      extend ActiveSupport::Concern
      included do
        has_many :collections,
          predicate: ActiveFedora::RDF::Fcrepo::RelsExt.hasPart,
          class_name: "ActiveFedora::Base"
      end
    end
  end
end
