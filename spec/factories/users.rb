FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password 'password'

    trait :photographer do
      login "photographer"
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
      display_name "Conservation Department"
    end
  end
end
