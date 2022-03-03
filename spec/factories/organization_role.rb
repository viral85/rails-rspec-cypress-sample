FactoryBot.define do
  factory :organization_role do
    text { "Prosecuting Attorney" }
    spanish_text { "Abogado Fiscal" }
    organization

    trait :role2 do
      text { "Witness" }
      spanish_text { "Testigo" }
    end

    trait :role3 do
      text { "Defense Attorney" }
      spanish_text { "Abogado de la defensa" }
    end
  end
end
