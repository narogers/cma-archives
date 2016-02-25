FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }

    factory :photographer do
      display_name "Photography Studio"
      groups [:photostudio]
    end

    factory :archivist do
      display_name "Archivist"
      groups [:archives]
    end

    factory :administrator do
      display_name "Administrator"
      groups [:admin]
    end
  end
end
