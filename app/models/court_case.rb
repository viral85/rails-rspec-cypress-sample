class CourtCase < ApplicationRecord
  include Token

  # Associations
  belongs_to :user
  belongs_to :organization
  has_many :attendances, dependent: :destroy
  has_many :participants, through: :attendances

  before_validation :generate_friendly_token

  enum meeting_status: { pending: 0, active: 1, ended: 2, abandoned: 3 }

  scope :not_ended_today, -> {
    where(
      "last_meeting_ended_at < ? OR last_meeting_ended_at is NULL",
      Time.zone.now.beginning_of_day
    )
  }

  after_save :clean_up_attendances, if: :saved_change_to_meeting_status?

  def participants_in_meeting_room
    Participant.includes(:court_cases, :attendances)
               .where(
                 "court_cases.id = ? AND (participants.zoom_status = ? OR "\
                 "participants.zoom_status = ?)",
                 id, Participant.zoom_statuses[:loading_state],
                 Participant.zoom_statuses[:meeting_room]
               )
               .references(:court_cases, :attendances)
               .order("entered_waiting_room_at")
  end

  def participants_allowed_to_enter_meeting_room
    Participant.includes(:court_cases, :attendances)
               .where(
                 "court_cases.id = ? AND (participants.zoom_status = ? OR "\
                 "participants.zoom_status = ?)",
                 id, Participant.zoom_statuses[:loading_state],
                 Participant.zoom_statuses[:meeting_room]
               )
               .references(:court_cases, :attendances)
  end

  def participants_in_waiting_room
    Participant.includes(:court_cases, :attendances)
               .where("court_cases.id = ? AND participants.zoom_status = ?",
                      id, Participant.zoom_statuses[:waiting_room])
               .references(:court_cases, :attendances).order("entered_waiting_room_at")
  end

  def active_participants_count
    participants_in_meeting_room.count + participants_in_waiting_room.count
  end

  def set_case_to_active
    update!(meeting_status: "active", started_at: Time.zone.now) unless active?
  end

  def today_attendances
    attendances.where("created_at > ?", Time.zone.now.beginning_of_day)
  end

  def clean_up_attendances
    attendances.each(&:destroy) if ended?
  end
end
