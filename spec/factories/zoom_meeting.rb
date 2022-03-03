FactoryBot.define do
  factory :zoom_meeting do
    meeting_id { 94_446_976_353 }
    uuid { "ByocNJ/RL2kc/uvZ0g64Q==" }
    topic { "topic name" }
    join_url { "join url" }
    registration_url { "https://zoom.us/sample_registration_url" }
    password { "pwd" }
    meeting_type { 8 }
    user { User.first || FactoryBot.create(:user) }
    last_response { { occurrences: [{ occurrence_id: 1 }] } }

    trait :with_disable_registration do
      registration_url { nil }
      last_response { [] }
    end
  end
end
