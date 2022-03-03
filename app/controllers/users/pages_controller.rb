module Users
  class PagesController < UsersController
    before_action :verify_zoom_identity_presence, except: %i[no_access]
    before_action :authenticate_user!, except: %i[no_access]
    before_action :set_user_navbar, except: %i[no_access]
    before_action :set_old_logo_url, only: [:upload_logo]

    def home
      @user = current_user
      @user.zoom_meeting&.update_from_zoom
      @zoom_meeting = @user.zoom_meeting

      return unless params[:onboarding_completed] == "true"

      redirect_to root_path, notice: "Great job! You are ready to start using xyz.io"
    end

    def getting_started
      set_steps_state
    end

    def settings
      @user = current_user
      @zoom_meeting = @user.zoom_meeting
      @roles = @user.user_roles.order(position: :asc)
    end

    def ui_samples; end

    def create_zoom_meeting
      @user = current_user
      SetupZoomMeetingService.new(user: @user).call
      redirect_to root_path, notice: "Zoom meeting created successfully"
    end

    def update_zoom_meeting_type
      @user = current_user
      @user.zoom_meeting.update_meeting_type_in_zoom
      redirect_to root_path, notice: "Zoom meeting modified successfully"
    end

    def upload_logo
      begin
        service = UploadUserLogoService.new(user: current_user,
                                            params_logo: params.dig("user_setting", "logo"))
        upload, notice = service.call
        track_in_segment(@old_logo_url, current_user.user_settings.logo.url) if upload
      rescue CloudinaryException => e
        notice = handle_cloudinary_exception(e)
      end
      redirect_to settings_path, notice
    end

    def remove_logo
      UploadUserLogoService.new(user: current_user,
                                params_logo: nil).remove_logo
      redirect_to settings_path, notice: "Your logo was removed successfully"
    end

    def no_access; end

    private

    def handle_cloudinary_exception(error)
      if error.message.include?("File size too large.")
        { alert: "File size too large." }
      else
        { alert: "Please add valid image file" }
      end
    end

    def set_old_logo_url
      @old_logo_url = current_user.user_settings.logo.url
    end

    def set_user_navbar
      @show_user_nav = true
    end

    def verify_zoom_identity_presence
      return unless current_user.present? && current_user&.zoom_identity.nil?

      set_uninstall_cookie
      redirect_to destroy_user_session_path
    end

    def set_uninstall_cookie
      cookies[:xyz_uninstall] =
        { value: true, expires: Time.zone.now + 1.minute, domain: :all }
    end

    def track_in_segment(old_logo, new_logo)
      event = {
        "type": "track",
        "title": "Uploaded a new logo",
        "properties": { old_logo_url: old_logo, new_logo_url: new_logo }
      }
      SegmentWorker.perform_async(current_user.id, event)
    end

    def set_steps_state
      @step1_completed = current_user.onboarding.completed_step1
      @step2_completed = current_user.onboarding.completed_step2
      @step3_completed = current_user.onboarding.completed_step3
    end
  end
end
