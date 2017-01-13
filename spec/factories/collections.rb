FactoryGirl.define do
  factory :collection_hash, class: Hash do
    skip_create

    title { Faker::Lorem.words(3).join(" ").titleize }
    description { Faker::Lorem.paragraph }  

    initialize_with { attributes }
  end

  factory :collection do
    title { Faker::Lorem.words(3).join(" ") }
    description { Faker::Lorem.paragraph }
    depositor { "test" }
    edit_users {["test"]}
    administrative_collection

    factory :editorial_collection do
      association :administrative_collection, factory: :editorial_policy
    end
   
    factory :object_photography_collection do
      association :administrative_collection, factory: :object_photography_policy
    end

    factory :conservation_collection do
      association :administrative_collection, factory: :conservation_policy
    end
  end
end
