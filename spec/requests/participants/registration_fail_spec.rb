require "rails_helper"

RSpec.describe "Participants::Registrations" do
  let(:user) { create(:user, first_name: "Jane", last_name: "Dev") }

  before do
    StubRequests::Zoom::Registrant.new.failure
    create(:organization, :with_disable_cms)
    create(:zoom_meeting, user: user)
    create(:identity, user: user)
  end

  describe "zoom registrants api fail" do
    before do
      params = { locale: :es }
      params[:participant] = { first_name: "Register", last_name: "Error", role: "Witness" }
      post participants_path("123456", l: :es), params: params
    end

    it "shows zoom registration error redirects" do
      expect(response).to redirect_to(zoom_registration_error_path(user.token))
    end
  end

  describe "zoom registrants api fail message" do
    before do
      params = { locale: :es }
      params[:participant] = { first_name: "Register", last_name: "Error", role: "Witness" }
      post participants_path("123456"), params: params
      follow_redirect!
    end

    it "shows zoom registration error message" do
      expect(response.body).to include(I18n.t("reg.zoom_api_error", loale: :en))
    end

    it "shows retry message" do
      expect(response.body).to include(I18n.t("reg.re_registration", loale: :en))
    end

    it "shows retry registration button" do
      expect(response.body).to include(I18n.t("reg.retry", loale: :en))
    end
  end

  describe "zoom registrants api fail message in spanish" do
    before do
      params = { locale: :es }
      params[:participant] = { first_name: "Register", last_name: "Error", role: "Witness" }
      post participants_path("123456", l: :es), params: params
      follow_redirect!
    end

    it "shows zoom registration error message" do
      expect(response.body).to include(I18n.t("reg.zoom_api_error", loale: :es))
    end

    it "shows retry message" do
      expect(response.body).to include(I18n.t("reg.re_registration", loale: :es))
    end

    it "shows retry registration button" do
      expect(response.body).to include(I18n.t("reg.retry", loale: :es))
    end
  end
end
