class FeaturedCollection < ActiveRecord::Base
  attr_accessor :collection_solr_document

  def icon
    "" 
  end
end
