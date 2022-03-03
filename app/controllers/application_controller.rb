class ApplicationController < ActionController::Base
  protect_from_forgery
  before_action :configure_permitted_parameters, if: :devise_controller?
  around_action :switch_locale
  helper_method :time_difference

  before_action :authorize_requests_for_profiler

  def authorize_requests_for_profiler
    Rack::MiniProfiler.authorize_request if Rails.env.development?
  end

  def time_difference(start_time, end_time)
    seconds_diff = (start_time - end_time).abs
    Time.at(seconds_diff).utc.strftime "%H:%M:%S"
  end

  def new_session_path(_scope)
    new_user_session_path
  end

  def after_sign_in_path_for(resource)
    initial_page = current_user.sign_in_count == 1 ? getting_started_path : root_path
    stored_location_for(resource) || initial_page
  end

  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_path
  end

  def switch_locale(&action)
    chosen_locale = params[:l] || extract_locale_from_accept_language_header || I18n.default_locale
    locale = supported_locale(chosen_locale)
    I18n.with_locale(locale, &action)
  end

  rescue_from ActiveRecord::RecordNotFound do |_exception|
    render file: Rails.root.join("public/404.html"), layout: false, status: :not_found
  end

  rescue_from OAuth2::Error do |exception|
    error_message = HandleOauth2ErrorService.new(exception: exception).call
    sign_out(User)
    redirect_to new_user_session_path, alert: t(error_message)
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[first_name last_name])
  end

  private

  def supported_locale(chosen_locale)
    I18n.available_locales.map(&:to_s).include?(chosen_locale) ? chosen_locale : I18n.default_locale
  end

  def extract_locale_from_accept_language_header
    request.env["HTTP_ACCEPT_LANGUAGE"]&.scan(/^[a-z]{2}/)&.first
  end
end
