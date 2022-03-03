FactoryBot.define do
  factory :approved_domain do
    domain { "acme.com" }
    organization
  end
end
