class ZoomMeetingUpdateService
  include ZoomWebhookMeetingPayloadGettersConcern
  def initialize(params:, user:, meeting:)
    @params = params
    @user = user
    @meeting = meeting
  end

  def call
    change_meeting_topic if payload_object_topic.present?
    change_meeting_password if payload_object_password.present?
  end

  private

  def change_meeting_topic
    @meeting.update(topic: payload_object_topic)
  end

  def change_meeting_password
    @meeting.update(password: payload_object_password, join_url: payload_object_join_url)
    @user.participants.destroy_all
  end
end
