class HandleOauth2ErrorService
  def initialize(exception:)
    @exception = exception
  end

  def call
    handle_oauth2_error
  end

  private

  def handle_oauth2_error
    error_message = :oauth2_general_error
    reason = @exception.response.parsed["reason"]
    error = @exception.response.parsed["error"]
    if error == "invalid_request" && reason == "Invalid Token!"
      error_message = :oauth2_invalid_token_error
    else
      Honeybadger.notify(@exception)
    end
    error_message
  end
end
