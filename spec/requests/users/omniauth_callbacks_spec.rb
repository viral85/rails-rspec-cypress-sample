require "rails_helper"

RSpec.describe "Users::OmniauthCallbacksController", type: :request do
  describe "GET /users/auth/zoom/callback" do
    before do
      Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]
      Rails.application.env_config["omniauth.auth"] = zoom_hash
      StubRequests.stub
    end

    it "redirects to the home page" do
      FactoryBot.create(:organization_with_approved_domain)
      get "/users/auth/zoom/callback?code=DUMMY_CODE&state=DUMMY_STATE"
      expect(response).to redirect_to(getting_started_path)
    end

    it "shows the signed in message" do
      create(:organization_with_approved_domain)
      get "/users/auth/zoom/callback?code=DUMMY_CODE&state=DUMMY_STATE"
      follow_redirect!

      expect(response.body).to include("Signed in successfully!")
    end

    it "shows the organization user limit message" do
      create(:organization_with_approved_domain, user_limit: 0)
      get "/users/auth/zoom/callback?code=DUMMY_CODE&state=DUMMY_STATE"
      follow_redirect!

      expect(response.body).to include("Your organization has reached its user limit.")
    end

    it "allow to sign in" do
      create(:user, email: "user@acme.com",
                    organization: create(:organization_with_approved_domain))

      get "/users/auth/zoom/callback?code=DUMMY_CODE&state=DUMMY_STATE"

      expect(response).to redirect_to(root_path)
    end
  end

  describe "organization error" do
    before do
      Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]
      Rails.application.env_config["omniauth.auth"] = zoom_organization_error
    end

    it "shows organization not found message" do
      create(:organization_with_approved_domain)
      get "/users/auth/zoom/callback?code=DUMMY_CODE&state=DUMMY_STATE"
      follow_redirect!

      expect(response.body).to include("We could not find the organization using your email.")
    end
  end

  describe "OAuth2::Error invalid token" do
    before do
      Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]
      Rails.application.env_config["omniauth.auth"] = zoom_hash
      StubRequests::Zoom::OauthToken.new.invalid_token
      create(:organization_with_approved_domain)
      get "/users/auth/zoom/callback?code=DUMMY_CODE&state=DUMMY_STATE"
      follow_redirect!
    end

    it "shows oauth2 invalid token message" do
      expect(response.body).to include(I18n.t(:oauth2_invalid_token_error))
    end
  end

  describe "OAuth2::Error oauth2 general error" do
    before do
      Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]
      Rails.application.env_config["omniauth.auth"] = zoom_hash
      create(:organization_with_approved_domain)
      get "/users/auth/zoom/callback?code=DUMMY_CODE&state=DUMMY_STATE"
      follow_redirect!
    end

    it "shows oauth2 general error message" do
      expect(response.body).to include(I18n.t(:oauth2_general_error))
    end
  end
end
