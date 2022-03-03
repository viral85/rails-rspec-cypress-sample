class GenerateZoomCredentialsService
  def initialize(user:, participant: nil)
    @user = user
    @participant = participant
    set_api_keys
    set_meeting
  end

  def call
    return unless @api_key && @api_secret_key

    generate_zoom_credentials
  end

  private

  def generate_zoom_credentials
    {
      return_url: @user.root_url,
      signature: generate_signature,
      api_key: @api_key,
      meeting_number: @meeting_number,
      meeting_password: @meeting_password,
      participant_user_name: user_name
    }
  end

  def set_api_keys
    if Rails.env.development?
      @api_key = Rails.application.credentials.zoom[:jwt_app_api_key]
      @api_secret_key = Rails.application.credentials.zoom[:jwt_app_api_secret]
    else
      @api_key = @user&.organization&.jwt_api_key
      @api_secret_key = @user&.organization&.jwt_api_secret
    end
  end

  def set_meeting
    @meeting_number = @user.zoom_meeting.meeting_id
    @meeting_password = @user.zoom_meeting.password
    @role = host_role
  end

  def host_role
    1 # join as cohost
  end

  def user_name
    (@participant || @user).to_s
  end

  def generate_signature
    timestamp = (Time.current.to_i * 1000).round - 30_000

    message = Base64.strict_encode64("#{@api_key}#{@meeting_number}#{timestamp}#{@role}")

    hash = Base64.strict_encode64(
      OpenSSL::HMAC.digest("sha256", @api_secret_key, message)
    )

    Base64.strict_encode64("#{@api_key}.#{@meeting_number}.#{timestamp}.#{@role}.#{hash}")
  end
end
