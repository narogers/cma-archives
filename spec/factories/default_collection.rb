FactoryGirl.define do
  factory :collection_hash, class: Hash do
    skip_create

    title { Faker::Lorem.words(3).join(" ").titleize }
    description { Faker::Lorem.paragraph }  

    initialize_with { attributes }
  end
end
