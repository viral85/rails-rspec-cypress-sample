module WebhookBroadcasterConcern
  extend ActiveSupport::Concern

  private

  def set_broadcast_cargo
    @broadcast_cargo = BroadcastCargo.new(user: @user)
    if @participant.court_cases.present?
      @broadcast_cargo.capture_involved_cases_for([@participant])
    else
      @broadcast_cargo.capture_ungrouped_participant(participant: @participant)
    end
  end
end
