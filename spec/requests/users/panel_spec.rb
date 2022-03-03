require "rails_helper"

RSpec.describe "Users::PanelController", type: :request do
  describe "GET /panel" do
    it "is not accessible to unauthenticated user" do
      get panel_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "is accessible for authenticated user" do
      sign_in(create(:user))
      create(:zoom_meeting)
      get panel_path
      expect(response).to have_http_status(:ok)
    end
  end
end
