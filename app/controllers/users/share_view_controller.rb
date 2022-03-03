module Users
  class ShareViewController < ApplicationController
    before_action :redirect_user_from_view_only_to_home

    def index
      cookies.delete :xyz_participant, domain: :all
      cookies.delete :xyz_guest_token, domain: :all
      @panel = Panel.find_by(share_token: params[:id])
      @user = @panel&.user

      set_invitor_token_cookie
      set_invited_user_token_cookie
    end

    private

    def set_zoom_data
      @zoom_data =
        GenerateZoomCredentialsService.new(user: current_user).call
    end

    def set_invited_user_token_cookie
      cookies[:xyz_invited_user_token] =
        { value: SecureRandom.hex(10), expires: cookie_expiration_time, domain: :all }
    end

    def set_invitor_token_cookie
      cookies[:xyz_invitor_token] =
        { value: @panel&.share_token, expires: cookie_expiration_time, domain: :all }
    end

    def cookie_expiration_time
      Time.zone.now.end_of_day + 3.hours
    end

    def redirect_user_from_view_only_to_home
      redirect_to root_path if current_user.present?
    end
  end
end
