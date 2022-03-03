class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :zoom

  def zoom
    user_omni_auth_service = UserOmniAuthService.new(auth_hash: request.env["omniauth.auth"])
    @user = user_omni_auth_service.call
    if @user.persisted? && @user.zoom_identity.present?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", kind: "Zoom"
      sign_in_and_redirect @user, event: :authentication
    else
      session["devise.zoom"] = request.env["omniauth.auth"].except(:extra)
      error_for_different_organization
      redirect_to new_user_session_url, alert: @user.errors.full_messages.join("\n")
    end
  end

  private

  def error_for_different_organization
    return if @user.zoom_identity.present?

    @user.errors.add(:base, "We could not find the"\
    "organization using your email.")
  end
end
