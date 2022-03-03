require "rails_helper"

RSpec.describe "Participants::Registrations", type: :request do
  let(:organization) { create(:organization, :with_disable_cms, :with_roles) }
  let(:user) { create(:user, first_name: "Jane", last_name: "Dev", organization: organization) }

  before do
    create(:identity, user: user)
  end

  describe "GET /registration" do
    before do
      create(:zoom_meeting, user: user)
      get registration_path("123456")
    end

    it "is accessible to unauthenticated users" do
      expect(response.body).to include("topic name - Registration")
    end

    it "shows Prosecuting Attorney role in roles dropdown" do
      expect(response.body).to include("Prosecuting Attorney")
    end

    it "shows Witness role in roles dropdown" do
      expect(response.body).to include("Witness")
    end

    it "shows Defense Attorney role in roles dropdown" do
      expect(response.body).to include("Defense Attorney")
    end

    it "shows first name label" do
      expect(response.body).to include("First Name")
    end

    it "shows last name label" do
      expect(response.body).to include("Last Name")
    end

    it "shows role label" do
      expect(response.body).to include("Role")
    end

    it "shows Select Your Role" do
      expect(response.body).to include("Select your Role")
    end

    it "shows Register Button" do
      expect(response.body).to include("Register")
    end
  end

  describe "GET /registration with Spanish" do
    before do
      create(:zoom_meeting, user: user)
      get registration_path("123456", l: :es)
    end

    it "is accessible to unauthenticated users" do
      expect(response.body).to include("topic name - #{I18n.t('reg.title', locale: :es)}")
    end

    it "shows Prosecuting Attorney role in roles dropdown" do
      expect(response.body).to include("Abogado Fiscal")
    end

    it "shows Witness role in roles dropdown" do
      expect(response.body).to include("Testigo")
    end

    it "shows Defense Attorney role in roles dropdown" do
      expect(response.body).to include("Abogado de la defensa")
    end

    it "shows first name label in spanish" do
      expect(response.body).to include(I18n.t("reg.first_name", locale: :es))
    end

    it "shows last name label in spanish" do
      expect(response.body).to include(I18n.t("reg.last_name", locale: :es))
    end

    it "shows role label in spanish" do
      expect(response.body).to include(I18n.t("reg.role", locale: :es))
    end

    it "shows select your role in spanish" do
      expect(response.body).to include(I18n.t("reg.role_prompt", locale: :es))
    end

    it "shows Register Button" do
      expect(response.body).to include(I18n.t("reg.submit", locale: :es))
    end
  end

  describe "GET /registration with logged in user" do
    before do
      create(:zoom_meeting, user: user)
      sign_in(user)
      get registration_path("123456")
    end

    it "allow to register" do
      text = "To be part of the virtual hearing please register with your information"
      expect(response.body).to include(text)
    end
  end

  describe "GET /registration with wrong user token" do
    before do
      create(:zoom_meeting, user: user)
      get registration_path("123451")
    end

    it "return with status 404" do
      expect(response).to have_http_status(:not_found)
    end

    it "shows page doesn't exist" do
      expect(response.body).to include("The page you were looking for doesn't exist.")
    end
  end

  describe "GET /registration with disable registration" do
    before do
      create(:zoom_meeting, :with_disable_registration, user: user)
      get registration_path("123456")
    end

    it "redirect to registration_disabled page" do
      expect(response).to redirect_to(registration_disabled_path(123_456))
    end

    it "shows registration disable warning" do
      follow_redirect!
      expect(response.body).to include("We are sorry but this registration page has been disabled.")
    end
  end
end
