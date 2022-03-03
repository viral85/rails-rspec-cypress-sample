FactoryBot.define do
  factory :user do
    email { "email@domain.com" }
    first_name { "Firstname" }
    last_name { "Lastname" }
    token { "123456" }
    organization do
      Organization.first || FactoryBot.create(:organization_with_approved_domain, :with_roles)
    end
    sign_in_count { 1 }
  end
end
