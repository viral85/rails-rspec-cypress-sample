require "rails_helper"

RSpec.describe "Users::SessionsController", type: :request do
  describe "GET /login" do
    it "is accessible for unauthenticated user" do
      get new_user_session_path
      expect(response).to have_http_status(:ok)
    end

    it "redirects to home page" do
      sign_in(create(:user))
      get new_user_session_path
      expect(response).to redirect_to(root_path)
    end

    it "shows already signed in message" do
      sign_in(create(:user))
      create(:identity)
      get new_user_session_path
      follow_redirect!

      expect(response.body).to include("You are already signed in.")
    end
  end

  describe "GET /logout" do
    it "can not change header" do
      get destroy_user_session_path
      expect(response.headers.to_s).not_to include("xyz_signed_in_as_user")
    end

    it "adds the header" do
      sign_in(create(:user))
      get destroy_user_session_path
      expect(response.headers.to_s).to include("xyz_signed_in_as_user")
    end

    it "redirects to login page" do
      get destroy_user_session_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "shows the logout message" do
      sign_in(create(:user))
      get destroy_user_session_path
      follow_redirect!

      expect(response.body).to include("Signed out successfully")
    end
  end
end
