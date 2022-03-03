module ZoomWebhookMeetingPayloadGettersConcern
  extend ActiveSupport::Concern

  private

  def payload_object_topic
    @params["payload"]["object"]["topic"]
  end

  def payload_object_password
    @params["payload"]["object"]["password"]
  end

  def payload_object_join_url
    @params["payload"]["object"]["join_url"]
  end
end
