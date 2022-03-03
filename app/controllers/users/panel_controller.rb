module Users
  class PanelController < ApplicationController
    before_action :authenticate_user!, except: :view_only_panel
    before_action :redirect_basic_plan_user_to_home_page, except: :view_only_panel
    before_action :set_court_cases_string, except: :view_only_panel
    before_action :redirect_user_from_view_only_to_home, only: :view_only_panel

    def panel
      @user = current_user
      set_zoom_meeting_status
      track_in_segment
      unless @stimulus_reflex
        set_zoom_data
        @active_tab = current_user.cms_disabled? ? "participants" : "cases"
      end
      @host_panel = true
      render :host_panel
    end

    def view_only_panel
      @user = invitor_user
      return redirect_to no_access_path if @user.blank?

      set_zoom_meeting_status
      @host_panel = false
    end

    private

    def set_court_cases_string
      @court_cases_string = current_user.existing_available_cases_string
    end

    def set_zoom_data
      @zoom_data =
        GenerateZoomCredentialsService.new(user: current_user).call
    end

    def set_zoom_meeting_status
      zoom_api_get_meeting_response = GetZoomMeetingService.new(user: @user).call
      @zoom_meeting_status = zoom_api_get_meeting_response["status"]
      @zoom_meeting_title = zoom_api_get_meeting_response["topic"]
    end

    def redirect_basic_plan_user_to_home_page
      redirect_to root_path if current_user.zoom_basic_plan?
    end

    def track_in_segment
      event = { "type": "track", "title": "Accessed Control Panel" }
      SegmentWorker.perform_async(current_user.id, event)
    end

    def invitor_user
      invitor_token = cookies[:xyz_invitor_token]
      User.includes(:panel).where(panel: { share_token: invitor_token }).first
    end

    def cookie_expiration_time
      Time.zone.now.end_of_day + 3.hours
    end

    def redirect_user_from_view_only_to_home
      redirect_to root_path if current_user.present?
    end
  end
end
