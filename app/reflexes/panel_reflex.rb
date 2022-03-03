# frozen_string_literal: true

class PanelReflex < ApplicationReflex
  before_reflex :disable_morph, except: %i[full_update_panel]

  after_reflex :set_tab_to_cases,
               only: %i[start_case end_case filter_upcoming_cases admit_participant unassign_from_case
                        put_in_waiting_room toggle_view_case_paricipants remove_from_meeting
                        remove_from_control_panel]

  after_reflex :set_tab_to_participants,
               only: %i[admit_ungrouped_participant assign_to_case put_in_waiting_room_ungrouped
                        update_participant remove_ungrouped_from_control_panel
                        update_participant_zoom_username]

  delegate :admit_ungrouped_participant, :put_in_waiting_room_ungrouped,
           :remove_ungrouped_from_meeting, :remove_ungrouped_from_control_panel,
           to: :manage_ungrouped_participant_service

  delegate :start_case, :end_case, :admit_all, :put_all_in_waiting_room,
           to: :manage_case_service

  delegate :admit_participant, :start_case_with_single_participant, :put_in_waiting_room,
           :remove_from_meeting, :remove_from_control_panel, :unassign_from_case,
           to: :manage_case_participant

  def assign_to_case(case_numbers)
    AssignToCasesService.new(case_numbers: case_numbers, participant: participant).call
  end

  def update_participant(participant_token, first_name, last_name, role)
    @participant_token = participant_token
    ManageUngroupedParticipantService.new(user: current_user, participant: participant)
                                     .update_participant(first_name, last_name, role)
  end

  def filter_upcoming_cases(search_query)
    SearchService.new(
      search_query: search_query, user: current_user, invited_user_token: invited_user_token
    ).filter_upcoming_cases
  end

  def full_update_panel(active_tab)
    @active_tab = active_tab
  end

  def toggle_view_case_paricipants
    ManageCaseParticipantService.new(
      court_case: court_case, user: current_user, participant: participant
    ).toggle_view_case_paricipants
  end

  private

  def manage_ungrouped_participant_service
    ManageUngroupedParticipantService.new(
      user: current_user, participant: participant
    )
  end

  def manage_case_service
    ManageCaseService.new(court_case: court_case, user: current_user)
  end

  def manage_case_participant
    ManageCaseParticipantService.new(
      court_case: court_case, user: current_user, participant: participant
    )
  end

  def current_participant
    client if connection.participant?
  end

  def invited_user_token
    connection.invited_user_token
  end

  def case_number
    element.dataset[:case_number]
  end

  def participant_token
    element.dataset[:participant_token]
  end

  def participant
    token = participant_token || @participant_token
    current_user.participants.find_by(token: token) if token.present?
  end

  def court_case
    current_user.court_cases.find_by(case_number: case_number) if case_number.present?
  end

  def set_tab_to_cases
    @active_tab = "cases"
  end

  def set_tab_to_participants
    @active_tab = "participant"
  end

  def disable_morph
    morph :nothing
  end
end
