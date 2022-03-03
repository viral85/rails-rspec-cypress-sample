require "rails_helper"

RSpec.describe "Participants::Registrations", type: :request do
  before do
    StubRequests::Zoom::Registrant.new.create
    create(:organization, :with_disable_cms)
    user = create(:user, first_name: "Jane", last_name: "Dev")
    create(:zoom_meeting, user: user)
    create(:identity, user: user)
  end

  describe "Participant registers in english" do
    before do
      params = {
        participant: {
          first_name: "Dev", last_name: "Thomas",
          role: "Witness", locale: "en"
        }
      }
      post participants_path("123456"), params: params
    end

    it "redirects to meeting link page" do
      expect(response).to redirect_to(meeting_link_path(123_456, l: :en))
    end
  end

  describe "After participant regisstration" do
    before do
      params = {
        participant: {
          first_name: "Dev", last_name: "Thomas",
          role: "Witness", locale: "en"
        }
      }
      post participants_path("123456"), params: params
      follow_redirect!
    end

    it "shows meeting link page header" do
      expect(response.body).to include(I18n.t("meeting_link.title"))
    end

    it "shows meeting link page body" do
      welcome_html = I18n.t("meeting_link.welcome_html", participant: "Dev Thomas")
      expect(response.body).to include(welcome_html)
    end

    it "shows Launch Zoom Meeting button" do
      expect(response.body).to include(I18n.t("meeting_link.launch_btn"))
    end
  end

  describe "Participant registers in Spanish" do
    before do
      params = {
        participant: {
          first_name: "Dev", last_name: "Thomas",
          role: "Witness", locale: "es"
        }
      }
      post participants_path("123456"), params: params
    end

    it "redirects to meeting link page with locale spanish" do
      expect(response).to redirect_to(meeting_link_path(123_456, l: :es))
    end
  end

  describe "After participant registers in Spanish" do
    before do
      params = {
        participant: {
          first_name: "Dev", last_name: "Thomas",
          role: "Witness", locale: "es"
        }
      }
      post participants_path("123456", l: :es), params: params
      follow_redirect!
    end

    it "shows meeting link page header in Spanish" do
      expect(response.body).to include(I18n.t("meeting_link.title", locale: :es))
    end

    it "shows meeting link page title in Spanish" do
      welcome_title = I18n.t("meeting_link.welcome_html", participant: "Dev Thomas", locale: :es)
      expect(response.body).to include(welcome_title)
    end

    it "shows Launch Zoom Meeting button in Spanish" do
      expect(response.body).to include(I18n.t("meeting_link.launch_btn", locale: :es))
    end
  end
end
