class BroadcastOperator
  include CableReady::Broadcaster

  def initialize(broadcast_cargo:, user:)
    @broadcast_cargo = broadcast_cargo
    @user = user
  end

  def call
    broadcast_cases if @broadcast_cargo.cases_packages.present?
    broadcast_ungrouped_participants if @broadcast_cargo.ungrouped_participants_packages.present?

    cable_ready.broadcast
  end

  private

  def broadcast_cases
    @case_broadcaster = CaseBroadcaster.new(user: @user, cable_ready: cable_ready)
    @broadcast_cargo.cases_packages.each do |case_package|
      broadcast_case(case_package)
    end
  end

  def broadcast_case(package)
    court_case = @user.court_cases.find(package[:court_case_id])
    initial_participants_number = package[:initial_participants_number]
    initial_meeting_status = package[:initial_meeting_status]

    @case_broadcaster.update_case(court_case, initial_participants_number, initial_meeting_status)
  end

  def broadcast_ungrouped_participants
    @ungrouped_participant_broadcaster =
      UngroupedParticipantBroadcaster.new(user: @user, cable_ready: cable_ready)
    @broadcast_cargo.ungrouped_participants_packages.each do |ungrouped_participant_package|
      broadcast_ungrouped_participant(ungrouped_participant_package)
    end
  end

  def broadcast_ungrouped_participant(package)
    ungrouped_participant = @user.participants.find(package[:ungrouped_participant_id])
    initial_court_cases_number = package[:initial_court_cases_number]
    initial_status = package[:initial_status]

    @ungrouped_participant_broadcaster.update_ungrouped_participant(
      ungrouped_participant, initial_court_cases_number, initial_status
    )
  end
end
