class Participant < ApplicationRecord
  has_secure_token
  serialize :event_body, Hash

  # Associations
  validates :first_name, presence: true
  belongs_to :user
  has_many :attendances, dependent: :destroy
  has_many :court_cases, through: :attendances
  belongs_to :current_meeting_room, class_name: "CourtCase", optional: true
  has_one :analytics_user, dependent: :destroy

  enum zoom_status: { inactive: 0, waiting_room: 1, loading_state: 2, meeting_room: 3 }

  scope :online, -> { where(zoom_status: %i[waiting_room loading_state meeting_room]) }
  scope :active, -> { where(zoom_status: %i[loading_state meeting_room]) }

  # Callbacks
  before_create :generate_email
  before_validation :strip_whitespace
  after_create :create_analytic_user, :identify_in_segment

  accepts_nested_attributes_for :court_cases, allow_destroy: true,
                                              reject_if: proc { |attr| attr["case_number"].blank? }

  def to_s
    "#{first_name} #{last_name}"
  end

  def full_name
    to_s
  end

  def create_analytic_user
    user = { participant_id: id,
             first_name: first_name,
             last_name: last_name,
             user_type: "participant" }
    AnalyticsUser.create(user)
  end

  def generate_email
    return if email.present?

    self.email = "info+#{token.downcase}@xyz.io"
  end

  def active?
    loading_state? || meeting_room?
  end

  def pending_and_active_cases
    court_cases.where(meeting_status: %w[pending active])
  end

  def ungrouped?
    pending_and_active_cases.blank?
  end

  def online?
    waiting_room? || loading_state? || meeting_room?
  end

  def strip_whitespace
    self.first_name = first_name.squeeze(" ").strip unless first_name.nil?
    self.last_name = last_name.squeeze(" ").strip unless last_name.nil?
  end

  def identify_in_segment
    event = { "type": "identify" }
    ParticipantSegmentWorker.perform_async(id, event)
  end
end
