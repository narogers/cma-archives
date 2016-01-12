class CreateFeaturedCollectionsTable < ActiveRecord::Migration
  def change
    create_table :featured_collections do |t|
      t.string :collection_id
      t.timestamps
    end

    add_index :featured_collections, :collection_id
  end
end
