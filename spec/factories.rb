FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }

    trait :photographer do
      login "photostudio"
      display_name "Photography Studio"
    end

    trait :archivist do
      login "archivist" 
      display_name "Archivist"
    end

    trait :administrator do
      login "administrator"
      display_name "Administrator"
    end
 
    trait :conservationist do
      login "conservationist"
      display_name "Conservation"
    end
  end
end
