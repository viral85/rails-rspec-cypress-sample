FactoryBot.define do
  factory :participant do
    first_name { "John" }
    last_name { "Doe" }
    token { "123456" }
    user_id { 1 }
    zoom_status { "loading_state" }
    role { "defense_attorney" }
  end
end
