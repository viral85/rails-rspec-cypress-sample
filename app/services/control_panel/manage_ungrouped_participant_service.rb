class ManageUngroupedParticipantService
  include BroadcasterConcern

  def initialize(user:, participant:)
    @user = user
    @participant = participant
    @update_sdk_availability_service = UpdateNextSdkAvailabilityService.new(user: @user)
    prepare_broadcast_cargo
  end

  def admit_ungrouped_participant
    @update_sdk_availability_service.call
    @participant.update(zoom_status: "loading_state")
    broadcast_updates
  end

  def put_in_waiting_room_ungrouped
    @update_sdk_availability_service.call
    @participant.update(zoom_status: "waiting_room")
    broadcast_updates
  end

  def remove_ungrouped_from_control_panel
    @participant.update(zoom_status: "inactive")
    broadcast_updates
  end

  def remove_ungrouped_from_meeting
    @update_sdk_availability_service.call(zoom_processing_duration: 5.6)
    @participant.update(zoom_status: "inactive")
    broadcast_updates
  end

  def update_participant(first_name, last_name, role)
    @update_sdk_availability_service.call(zoom_processing_duration: 5.6)
    zoom_username = "#{first_name} #{last_name} - #{role}"
    @participant.update(first_name: first_name, last_name: last_name, role: role,
                        zoom_username: zoom_username)
    broadcast_updates
  end

  private

  def prepare_broadcast_cargo
    @broadcast_cargo = BroadcastCargo.new(user: @user)
    @broadcast_cargo.capture_ungrouped_participant(participant: @participant)
  end
end
