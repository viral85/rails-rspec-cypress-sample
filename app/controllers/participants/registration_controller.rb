module Participants
  class RegistrationController < ParticipantsController
    before_action :redirect_to_update_browser_page, except: :update_browser
    before_action :set_user, except: :update_browser
    before_action :set_current_participant, except: :update_browser
    before_action :validate_zoom_meeting_prerequisits, only: :registration

    def registration
      @show_translation_link = true
      cookies.delete :xyz_participant, domain: :all
      @participant = Participant.new
      @zoom_meeting = @user&.zoom_meeting
      set_guest_cookie unless @stimulus_reflex
      @role_options = GetRegistrationRolesService.new(user: @user, locale: locale).call
    end

    def registration_disabled
      @zoom_meeting = @user&.zoom_meeting
      if @user&.zoom_meeting&.meets_prerequisites?
        redirect_to registration_path(params[:id])
      else
        Honeybadger.notify("Registration is disabled", context: registration_disable_context)
      end
    end

    def registration_cases
      redirect_to registration_path(id: @user.token) if cookies[:first_name].blank?
      @cases = cookies[:found_cases].split("&") if cookies[:found_cases].present?
      @participant = Participant.new
    end

    def search_cases
      if @user.organization.cms_enabled?
        cms_case_search
      else
        @cases = []
        create_participant_service_call
        redirect_to meeting_link_path(id: @user.token, l: params[:participant][:locale])
      end
    end

    def manage_participant
      @cases = params["button-b"].present? ? [] : set_cases_from_params
      create_participant_service_call
      if @participant
        redirect_to meeting_link_path(id: @user.token)
      else
        redirect_to registration_path(id: @user.token), alert: @participant_service.error
      end
    end

    rescue_from CreateRegistrantsError do |exception|
      Honeybadger.notify(exception.message, context: exception&.zoom_response&.parsed_response)
      redirect_to zoom_registration_error_path(@user.token)
    end

    def update_browser
      redirect_to new_user_session_path, alert: "Inaccessible page" unless browser.ie?
    end

    def zoom_error
      @show_translation_link = true
    end

    private

    def registration_disable_context
      {
        user_id: @user.id,
        user_token: @user.token,
        analytics_user_id: @user&.analytics_user&.id,
        ip: request.ip,
        meeting_registration_enabled: @zoom_meeting&.registration_enabled?,
        basic_zoom_plan: @user&.zoom_basic_plan?,
        recurring_with_fixed_time: @zoom_meeting&.recurring_with_fixed_time?,
        user_registration_page: @user&.registration_room_url
      }
    end

    def redirect_to_update_browser_page
      redirect_to update_browser_path if browser.ie?
    end

    def cms_case_search
      @search_court_cases_service = SearchCourtCasesService.new(params: reg_params)
      @cases = @search_court_cases_service.call
      if @cases && @cases.size == 1
        create_participant_service_call
        redirect_to meeting_link_path(id: @user.token)
      else
        set_form_cookies
        redirect_to registration_cases_path(id: @user.token)
      end
    end

    def create_participant_service_call
      @participant_service =
        CreateParticipantService.new(user: @user, params: reg_params,
                                     cookies: cookies, cases: @cases)
      @participant = @participant_service.call
      set_participant_cookie
      delete_guest_cookies
    end

    def set_cases_from_params
      cases = []
      params["participant"][:court_cases_attributes].to_enum.to_h.each do |c|
        cases.push(c[1]["case_number"])
      end
      cases
    end

    def set_user
      @user = User.find_by!(token: params[:id])
    end

    def set_current_participant
      @current_participant = Participant.find_by(token: cookies[:xyz_participant])
    end

    def reg_params
      params.require(:participant).permit(
        :first_name, :last_name, :role, :locale,
        court_cases_attributes: %I[_destroy case_number]
      )
    end

    def exp_time
      Time.zone.now.end_of_day
    end

    def set_guest_cookie
      cookies[:xyz_guest_token] =
        { value: SecureRandom.hex(10), expires: exp_time, domain: :all }
    end

    def set_participant_cookie
      cookies[:xyz_participant] =
        { value: @participant.token, expires: exp_time, domain: :all }
    end

    def validate_zoom_meeting_prerequisits
      return if @user&.zoom_meeting&.meets_prerequisites?

      redirect_to registration_disabled_path(params[:id])
    end

    def set_form_cookies
      cookies[:first_name] = { value: reg_params[:first_name], expires: exp_time, domain: :all }
      cookies[:last_name] = { value: reg_params[:last_name], expires: exp_time, domain: :all }
      cookies[:role] = { value: reg_params[:role], expires: exp_time, domain: :all }
      cookies[:locale] = { value: reg_params[:locale], expires: exp_time, domain: :all }
      cookies[:found_cases] = { value: @cases, expires: exp_time, domain: :all } if @cases
    end

    def delete_guest_cookies
      cookies.delete :xyz_guest_token, domain: :all
      cookies.delete :first_name, domain: :all
      cookies.delete :last_name, domain: :all
      cookies.delete :role, domain: :all
      cookies.delete :locale, domain: :all
      cookies.delete :found_cases, domain: :all
    end
  end
end
