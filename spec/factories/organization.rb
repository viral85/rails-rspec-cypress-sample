FactoryBot.define do
  factory :organization do
    name { "acme" }
    enable_cms { true }
    user_limit { nil }
    default_logo_url { "/courts/texas/tx-courts-default.png" }

    factory :organization_with_approved_domain do
      approved_domains { [association(:approved_domain)] }
    end

    trait :with_roles do
      organization_roles do
        [
          association(:organization_role),
          association(:organization_role, :role2),
          association(:organization_role, :role3)
        ]
      end
    end

    trait :with_disable_cms do
      enable_cms { false }
    end
  end
end
