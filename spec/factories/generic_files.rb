FactoryGirl.define do
  factory :generic_file do
    depositor "FactoryGirl"
    edit_users ["FactoryGirl"]

    trait :image do
      mime_type "image/tiff"
    end

    trait :audio do
      mime_type "audio/wav"
    end

    trait :video do 
      mime_type "video/mp4"
    end

    factory :generic_image, traits: [:image]
    factory :generic_audio, traits: [:audio]
    factory :generic_video, traits: [:video]
  end
end
