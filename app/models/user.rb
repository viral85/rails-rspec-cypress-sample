class User < ApplicationRecord
  include Token
  include CasesAttendances
  devise :rememberable, :trackable, :omniauthable, omniauth_providers: %i[zoom]

  # Associations
  belongs_to :organization
  has_many :identities, dependent: :destroy
  has_many :court_cases, dependent: :destroy
  has_many :attendances, dependent: :destroy
  has_many :participants, dependent: :destroy
  has_many :user_roles, dependent: :destroy
  has_one :analytics_user, dependent: :destroy
  has_one :zoom_meeting, dependent: :destroy
  has_one :user_settings, class_name: "UserSetting", dependent: :destroy
  has_one :onboarding, dependent: :destroy
  has_one :panel, dependent: :destroy

  # Delegtions
  delegate :cms_enabled?, :cms_disabled?, to: :organization

  # Callbacks
  before_validation :generate_friendly_token
  after_create :create_analytic_user, :create_settings, :create_onboarding_record, :create_panel

  # Validations
  validates :first_name, :last_name, :email, :organization_id, :token, presence: true

  def to_s
    full_name
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def initials
    "#{first_name[0]}#{last_name[0]}".upcase
  end

  def create_settings
    return unless user_roles.count.zero?

    organization&.organization_roles&.each do |org_role|
      user_roles.create(
        position: org_role.position, text: org_role.text,
        spanish_text: org_role.spanish_text, skip_tracking: true
      )
    end

    create_user_settings if user_settings.nil?
  end

  def update_identity_attributes
    return unless zoom_identity

    update(
      first_name: zoom_identity.first_name,
      last_name: zoom_identity.last_name,
      email: zoom_identity.email
    )
  end

  def zoom_basic_plan?
    zoom_plan == 1
  end

  def password_required?
    false
  end

  def zoom_identity
    identities&.where(provider: "zoom")&.last
  end

  def create_analytic_user
    user = { user_id: id,
             first_name: first_name,
             last_name: last_name,
             user_type: "user" }
    AnalyticsUser.create(user)
  end

  def registration_room_url
    "#{Rails.configuration.host_url}/r/#{token}"
  end

  def share_url
    "#{Rails.configuration.host_url}/vl/#{panel.share_token}"
  end

  def root_url
    "#{Rails.configuration.host_url}/"
  end

  def zoom_access_token
    return unless zoom_identity

    zoom_identity.updated_access_token
  end

  def sdk_request_available?
    return true if next_zoom_sdk_request_available_at.blank?

    next_zoom_sdk_request_available_at < Time.zone.now
  end

  def logo
    if user_settings&.logo&.key&.present?
      user_settings.logo.key
    elsif organization&.default_logo_url
      organization.default_logo_url
    end
  end

  def create_onboarding_record
    create_onboarding if onboarding.blank?
  end

  def registration_roles
    GetRegistrationRolesService.new(user: self, locale: nil).call
  end

  def existing_available_cases_string
    court_cases.where(meeting_status: %i[pending active])
               .not_ended_today.pluck(:case_number).join(" ")
  end
end
