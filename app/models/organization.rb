class Organization < ApplicationRecord
  # Associations
  has_many :users, dependent: :destroy
  has_many :court_cases, dependent: :destroy
  has_many :approved_domains, dependent: :destroy
  has_many :organization_roles, dependent: :destroy

  # Validations
  validates :name, presence: true

  encrypts :jwt_api_secret

  def within_user_limit?
    if user_limit
      user_limit > users.count
    else
      true
    end
  end

  def over_user_limit?
    !within_user_limit?
  end

  def cms_enabled?
    enable_cms
  end

  def cms_disabled?
    !enable_cms
  end
end
