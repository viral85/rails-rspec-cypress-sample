require "rails_helper"

RSpec.describe "Webhooks::ZoomWebhooksController", type: :request do
  let(:organization) { create(:organization, :with_disable_cms, :with_roles) }
  let(:user) { create(:user, first_name: "Jane", last_name: "Dev", organization: organization) }

  describe "/zoom_webhooks meeting.updated" do
    before do
      Sidekiq::Testing.inline!
      create(:zoom_meeting, user: user)
      create(:identity, user: user)

      payload = {
        operator_id: "KdYKjnimT4KPd8FFgQt9FQ",
        object: { id: 94_446_976_353,
                  topic: "New Meeting Topic", password: "228899", join_url: "New join url" }
      }
      params = { event_ts: 1_638_275_951_334,
                 event: "meeting.updated",
                 payload: payload }
      post zoom_webhooks_path, params: params, as: :json
    end

    it "check the meeting password updated" do
      expect(ZoomMeeting.first.password).to eq "228899"
    end

    it "check the meeting topic updated" do
      expect(ZoomMeeting.first.topic).to eq "New Meeting Topic"
    end

    it "check the meeting join url updated" do
      expect(ZoomMeeting.first.join_url).to eq "New join url"
    end
  end
end
