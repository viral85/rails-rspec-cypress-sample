module BroadcasterConcern
  extend ActiveSupport::Concern

  protected

  def broadcast_updates
    BroadcastOperator.new(broadcast_cargo: @broadcast_cargo, user: @user).call
  end
end
