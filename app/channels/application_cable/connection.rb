module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :client

    def connect
      self.client = identify_client
    end

    def client_is_participant?
      client.instance_of?(Participant)
    end

    def client_is_user?
      client.instance_of?(User)
    end

    def authorized_user?
      client.present? && client_is_user?
    end

    def participant?
      client.present? && client_is_participant?
    end

    def guest?
      cookies[:xyz_guest_token].present?
    end

    def guest_token
      cookies[:xyz_guest_token]
    end

    def valid_invited_user?
      invited_user_token.present? && invitor_user.present? && invitor_user.panel.sharing_enabled
    end

    def invitor_user
      User.includes(:panel).where(panel: { share_token: invitor_token }).first
    end

    def invited_user_token
      cookies[:xyz_invited_user_token]
    end

    def invitor_token
      cookies[:xyz_invitor_token]
    end

    protected

    def identify_client
      if (current_user = env["warden"].user(:user))
        current_user
      elsif (participant = fetch_participant)
        participant
      elsif guest?
        guest_token
      elsif valid_invited_user?
        invitor_token
      else reject_unauthorized_connection
      end
    end

    def fetch_participant
      Participant.find_by(token: cookies[:xyz_participant]) if cookies[:xyz_participant]
    end
  end
end
