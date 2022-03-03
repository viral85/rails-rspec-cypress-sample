require "rails_helper"

RSpec.describe "Users::PagesController", type: :request do
  describe "GET #home" do
    it "is not accessible to unauthenticated users" do
      get root_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "is accessible for authenticated users" do
      sign_in(create(:user))
      create(:identity)
      get root_path
      expect(response).to have_http_status(:ok)
    end

    it "allows authenticated users to sign out from the home page" do
      sign_in(create(:user))
      create(:identity)
      get root_path
      expect(response.body).to include("Sign Out")
    end
  end

  describe "GET #home with zoom meeting" do
    before do
      StubRequests.stub
      create(:organization_with_approved_domain)
      user = create(:user, first_name: "Jane", last_name: "Dev")
      create(:zoom_meeting, user: user)
      create(:identity, user: user)
      sign_in(user)
    end

    it "has user name" do
      get root_path
      expect(response.body).to include("Jane Dev")
    end

    it "has meeting number" do
      get root_path
      expect(response.body).to include("94446976353")
    end

    it "has launch controler panel button" do
      get root_path
      expect(response.body).to include("Launch Control Panel")
    end
  end

  describe "GET #home with modify zoom meeting button" do
    before do
      zoom_meeting_stub = StubRequests::Zoom::Meeting.new
      zoom_meeting_stub.meeting_with_registration_disabled
      create(:organization_with_approved_domain)
      user = create(:user, first_name: "Jane", last_name: "Dev")
      create(:zoom_meeting, user: user)
      create(:identity, user: user)
      sign_in(user)
    end

    it "has user name" do
      get root_path
      expect(response.body).to include("Jane Dev")
    end

    it "has modify zoom meeting button" do
      get root_path
      expect(response.body).to include("Modify Zoom Meeting")
    end

    it "has warning message 'incompatible zoom meeting'" do
      get root_path
      expect(response.body).to include("Incompatible Zoom Meeting")
    end
  end

  describe "GET /ui-samples" do
    it "is not accessible to unauthenticated user" do
      get "/ui-samples"
      expect(response).to redirect_to(new_user_session_path)
    end

    it "is accessible for authenticated user" do
      sign_in(create(:user))
      create(:identity)
      get "/ui-samples"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /create_zoom_meeting" do
    before do
      StubRequests.stub
    end

    let(:user) { create(:user, first_name: "Jane", last_name: "Dev") }

    it "is not accessible to unauthenticated user" do
      post create_zoom_meeting_path(user)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "is accessible for authenticated user" do
      create(:identity, user: user)
      sign_in(user)
      post create_zoom_meeting_path(user)
      expect(response).to redirect_to(root_path)
    end

    it "is redirect_to destroy_user_session_path" do
      sign_in(user)
      post create_zoom_meeting_path(user)
      expect(response).to redirect_to(destroy_user_session_path)
    end
  end
end
