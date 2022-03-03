class ManageCaseParticipantService
  include BroadcasterConcern

  def initialize(court_case:, user:, participant:)
    @user = user
    @court_case = court_case
    @participant = participant
    @update_sdk_availability_service = UpdateNextSdkAvailabilityService.new(user: @user)
    prepare_broadcast_cargo
  end

  def start_case_with_single_participant
    @update_sdk_availability_service.call
    @court_case.set_case_to_active
    @participant.update(zoom_status: "loading_state")
    broadcast_updates
  end

  def admit_participant
    @update_sdk_availability_service.call
    @participant.update(zoom_status: "loading_state")
    broadcast_updates
  end

  def put_in_waiting_room
    @update_sdk_availability_service.call
    @participant.update(zoom_status: "waiting_room")
    broadcast_updates
  end

  def remove_from_meeting
    @update_sdk_availability_service.call(zoom_processing_duration: 5.6)
    @participant.update(zoom_status: "inactive")
    broadcast_updates
  end

  def remove_from_control_panel
    @participant.update(zoom_status: "inactive")
    broadcast_updates
  end

  def unassign_from_case
    performs_sdk_request = @participant.active?
    @broadcast_cargo.capture_ungrouped_participant(participant: @participant)
    @participant.update(zoom_status: "waiting_room")
    @participant&.attendances&.destroy_all
    @court_case.abandoned! if @court_case.participants.count.zero?
    @update_sdk_availability_service.call if performs_sdk_request
    broadcast_updates
  end

  def toggle_view_case_paricipants
    @court_case.update(participants_list_expended: !@court_case.participants_list_expended)
    broadcast_updates
  end

  private

  def prepare_broadcast_cargo
    @broadcast_cargo = BroadcastCargo.new(user: @user)
    if @participant.present?
      @broadcast_cargo.capture_involved_cases_for([@participant])
    else
      @broadcast_cargo.capture_court_case(court_case: @court_case)
    end
  end
end
