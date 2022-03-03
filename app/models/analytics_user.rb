class AnalyticsUser < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :participant, optional: true
  enum user_type: { "user" => 0, "participant" => 1 }
end
