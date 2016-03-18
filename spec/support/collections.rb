module CollectionHelper
  def teardown name
    coll = Collection.find_with_conditions("title_tesim: \"#{name}\"")
    unless coll.blank?
      coll = Collection.find(coll.first["id"]).destroy
    end
  end
end

RSpec.configure do |config|
  config.include CollectionHelper
end
