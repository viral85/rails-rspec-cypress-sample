class ZoomWebhookRequest < ApplicationRecord
  # Validations
  validates :request, presence: true
end
