module ZoomWebhookPayloadGettersConcern
  extend ActiveSupport::Concern

  private

  def payload_email
    @params["payload"]["object"]["participant"]["email"]
  end

  def payload_username
    @params["payload"]["object"]["participant"]["user_name"]
  end

  def payload_zoom_user_id
    @params["payload"]["object"]["participant"]["user_id"]
  end

  def payload_meeting_id
    @params["payload"]["object"]["id"]
  end

  def payload_zoom_host_id
    @params["payload"]["object"]["host_id"] || @params["payload"]["operator_id"]
  end

  def payload_participant_id
    @params["payload"]["object"]["participant"]["id"]
  end

  def extract_token
    return nil unless payload_email.include?("info+")

    payload_email&.split("info+")&.last&.split("@")&.first
  end
end
