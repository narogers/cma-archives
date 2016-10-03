module CollectionHelper
  def find_by_title name
    field = ActiveFedora::SolrQueryBuilder.solr_name("title")
    query = ActiveFedora::SolrService.query("#{field}: \"#{name}\"",
      {rows: 1, fl: "id", fq: "has_model_ssim: Collection"})

    if query.count > 0
      Collection.find(query.first["id"])
    else
      nil
    end
  end

  def get_count name
    field = ActiveFedora::SolrQueryBuilder.solr_name("title")
    Collection.count(conditions: "#{field}: \"#{name}\"")
  end

  def teardown name
   coll = find_by_title(name)
   unless coll.nil?
      coll.destroy
   end
  end
end

RSpec.configure do |config|
  config.include CollectionHelper
end
