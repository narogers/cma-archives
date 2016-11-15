FactoryGirl.define do
  factory :collection_hash, class: Hash do
    skip_create

    title { Faker::Lorem.words(3).join(" ").titleize }
    description { Faker::Lorem.paragraph }  

    initialize_with { attributes }
  end

  factory :collection do
    depositor "test"
    edit_users ["test"]
    title { Faker::Lorem.words(3).join(" ") }
    description { Faker::Lorem.paragraph }
  end
end
