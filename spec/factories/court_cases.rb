FactoryBot.define do
  factory :court_case do
    case_number { "MyString" }
    user_id { 1 }
    meeting_status { 1 }
  end
end
