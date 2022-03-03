FactoryBot.define do
  factory :identity do
    provider { "zoom" }
    uid { "KdYKjnimT4KPd8FFgQt9FQ" }
    access_token { "access_token" }
    refresh_token { "REFRESH_TOKEN" }
    user { User.first || FactoryBot.create(:user) }
  end
end
