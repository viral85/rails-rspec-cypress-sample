class Attendance < ApplicationRecord
  has_secure_token :token

  # Associations
  belongs_to :user
  belongs_to :participant
  belongs_to :court_case, optional: true

  enum room: { waiting_room: 0, loading_state: 1, meeting_room: 2, ended: 3, removed: 4,
               failed_to_connect: 5, inactive: 6 }

  after_create :log_participant_history

  scope :from_ended_cases, -> {
    joins(:court_case).where(court_case: { meeting_status: CourtCase.meeting_statuses[:ended] })
  }

  scope :from_not_ended_cases, -> {
    joins(:court_case).where(court_case:
      {
        meeting_status: [
          CourtCase.meeting_statuses[:pending],
          CourtCase.meeting_statuses[:active]
        ]
      })
  }

  scope :ungrouped_attendances, -> {
    where(court_case: nil)
  }

  def log_participant_history
    ParticipantAttendancesHistory.create(
      user_id: user.id,
      participant_id: participant.id,
      first_name: participant.first_name,
      last_name: participant.last_name,
      court_case_number: court_case&.case_number,
      role: participant.role
    )
  end

  def active?
    loading_state? || meeting_room?
  end
end
