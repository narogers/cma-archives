FactoryGirl.define do
  factory :policies_hash, class: Hash do
    skip_create

    title { Faker::Lorem.words(3).join(" ").titleize }
    description { Faker::Lorem.paragraph }  
    read { "photostudio" }

    initialize_with { attributes }
  end

  factory :administrative_collection do
    title { [Faker::Lorem.words(3).join(" ").titleize] }
    description { [Faker::Lorem.paragraph] }
    after(:create) { |coll| coll.default_permissions.create(type: "group", access: "edit", name: "test") }

    factory :editorial_policy do
      after(:create) do |coll| 
        coll.default_permissions.create(type: "group", access: "read", 
          name: "photostudio")
      end
    end
   
    factory :object_photography_policy do
      after(:create) do |coll|
        coll.default_permissions.create(type: "group", access: "read", name: "photostudio")
        coll.default_permissions.create(type: "group", access: "read", name: "conservation")
      end
    end

    factory :conservation_policy do
      after(:create) do |coll| 
        coll.default_permissions.create(type: "group", access: "read", 
          name: "conservation")
        coll.save
      end
    end
  end
end
