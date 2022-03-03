class ManageCaseService
  include BroadcasterConcern

  def initialize(court_case:, user:)
    @user = user
    @court_case = court_case
    set_sdk_availability_service
    prepare_broadcast_cargo
  end

  def start_case
    @court_case.set_case_to_active
    load_waiting_participants
    @update_sdk_availability_service.call
    broadcast_updates
    track_in_segment
  end

  def end_case
    @update_sdk_availability_service.call(zoom_processing_duration: 5.6)
    remove_participants_from_meeting
    @court_case.update!(meeting_status: "ended", last_meeting_ended_at: Time.zone.now)
    broadcast_updates
  end

  def admit_all
    @court_case.participants_in_waiting_room.each do |participant|
      participant.update(zoom_status: "loading_state")
    end
    @update_sdk_availability_service.call
    broadcast_updates
  end

  def put_all_in_waiting_room
    @court_case.participants_in_meeting_room.each do |participant|
      participant.update(zoom_status: "waiting_room")
    end
    @update_sdk_availability_service.call
    broadcast_updates
  end

  private

  def set_sdk_availability_service
    @update_sdk_availability_service =
      UpdateNextSdkAvailabilityService.new(user: @user, court_case: @court_case)
  end

  def load_waiting_participants
    @court_case.participants_in_waiting_room.each do |participant|
      participant.update(zoom_status: "loading_state")
    end
  end

  def remove_participants_from_meeting
    @court_case.participants.each do |participant|
      if participant.attendances.count > 1
        participant.update(zoom_status: "waiting_room")
      else
        participant.update(zoom_status: "inactive")
      end
    end
  end

  def prepare_broadcast_cargo
    @broadcast_cargo = BroadcastCargo.new(user: @user)
    if @court_case&.participants&.present?
      @broadcast_cargo.capture_involved_cases_for(@court_case.participants)
    elsif @court_case.present?
      @broadcast_cargo.capture_court_case(court_case: @court_case)
    end
  end

  def track_in_segment
    event = {
      "type": "track",
      "title": "Started a Case",
      "properties": {
        case_number: @court_case&.case_number,
        organization_id: @user&.organization&.id
      }
    }
    SegmentWorker.perform_async(@user&.id, event)
  end
end
