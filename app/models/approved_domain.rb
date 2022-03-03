class ApprovedDomain < ApplicationRecord
  # Associations
  belongs_to :organization

  # Validations
  validates :domain, uniqueness: { case_sensitive: false }
end
