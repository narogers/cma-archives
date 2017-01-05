FactoryGirl.define do
  factory :generic_file do
    depositor "FactoryGirl"

    trait :image do
      mime_type "image/tiff"
    end

    trait :audio do
      mime_type "audio/wav"
    end

    trait :video do 
      mime_type "video/mp4"
    end

    trait :with_content do
      after(:create) do |file|
        file.add_file(File.new(File::NULL), {
          path: 'content',
          original_name: "lagoon.jpg",
          mime_type: "image/jpg"})
        file.import_url = "file://" + File.expand_path("spec/fixtures/lagoon.jpg")
        file.save   
      end
    end

    factory :generic_image, traits: [:image]
    factory :generic_image_with_content, traits: [:image, :with_content]
    factory :generic_audio, traits: [:audio]
    factory :generic_video, traits: [:video]
  end
end
