module Participants
  class RoomController < ParticipantsController
    before_action :set_user
    before_action :set_current_participant

    def meeting_link
      @show_translation_link = true
      redirect_to registration_path(params[:id]) unless can_access_meeting_link?
    end

    private

    def set_current_participant
      @current_participant = Participant.find_by(token: cookies[:xyz_participant])
    end

    def can_access_meeting_link?
      @current_participant.present?
    end

    def set_user
      @user = User.find_by!(token: params[:id])
    end
  end
end
