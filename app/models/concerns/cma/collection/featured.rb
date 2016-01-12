module CMA
  module Collection
    module Featured
      extend ActiveSupport::Concern

      def featured?
        FeaturedCollection.where(collection_id: id).exists?
      end
    end
  end
end

