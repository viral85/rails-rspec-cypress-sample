module CasesAttendances
  extend ActiveSupport::Concern

  def active_case
    court_cases.active.last
  end

  def search_cases_by_case_number(filter_by: nil)
    return if filter_by.blank?

    pending_cases_with_active_participants
      .where("court_cases.case_number ilike ?", "%#{filter_by}%")
      .joins(:participants).distinct.limit(2)
  end

  def pending_cases_with_active_participants
    court_cases.pending.joins(:attendances, :participants).where(
      "attendances.court_case_id is not NULL AND participants.zoom_status != ?",
      Participant.zoom_statuses[:inactive]
    ).distinct.order("created_at")
  end

  def total_cases_with_active_participants
    court_cases.joins(:attendances, :participants).where(
      "attendances.court_case_id is not NULL AND participants.zoom_status != ?",
      Participant.zoom_statuses[:inactive]
    ).distinct.order("created_at")
  end

  def ungrouped_participants
    Participant.where(user_id: id).where.missing(:attendances)
  end

  def ungrouped_available_participants
    ungrouped_participants.where(zoom_status: %i[waiting_room loading_state meeting_room])
                          .order("entered_waiting_room_at")
  end

  def display_cases?
    active_case.present? || pending_cases_with_active_participants.present?
  end

  def display_ungrouped_participants?
    ungrouped_available_participants.present?
  end

  def has_active_case? # rubocop:disable Naming/PredicateName
    active_case.present?
  end

  def has_no_active_case? # rubocop:disable Naming/PredicateName
    !has_active_case?
  end
end
