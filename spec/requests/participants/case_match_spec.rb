require "rails_helper"

RSpec.describe "Participants::Registrations search case service", type: :request do
  before do
    StubRequests::Zoom::Registrant.new.create
    create(:organization)
    user = create(:user, first_name: "Jane", last_name: "Dev")
    create(:zoom_meeting, user: user)
    create(:identity, user: user)
  end

  describe "Creating a participant that matches a single case" do
    before do
      params = { participant: { first_name: "Elon", last_name: "Musk", role: "Witness" } }
      post participants_path("123456"), params: params
    end

    it "redirects to meeting link page" do
      expect(response).to redirect_to(meeting_link_path(123_456))
    end

    it "creates a participant record" do
      expect(Participant.count).to eq(1)
    end

    it "creates an attendances record" do
      expect(Attendance.count).to eq(1)
    end

    it "creates a participant_attendances_histories record" do
      expect(ParticipantAttendancesHistory.count).to eq(1)
    end

    it "creates participant _attendances_history with court case number" do
      history = ParticipantAttendancesHistory.first
      expect(history.court_case_number).to eq("XYZ123")
    end
  end

  describe "Redirect to registration cases path with matched case numbers " do
    before do
      params = { participant: { first_name: "John", last_name: "Smith", role: "attorney" } }
      post participants_path("123456"), params: params
    end

    it "redirects to registration cases page" do
      expect(response).to redirect_to(registration_cases_path(123_456))
    end
  end

  describe "Creating a participant that matches multiple cases" do
    before do
      params = { participant: { first_name: "John", last_name: "Smith", role: "attorney" } }
      post participants_path("123456"), params: params
      follow_redirect!
    end

    it "check multiple case match text" do
      expect(response.body).to include("Multiple case match")
    end

    it "check participant name on page" do
      expect(response.body).to include("Hi John Smith,")
    end

    it "check number of matched case on page" do
      expect(response.body).to include("you have been matched to 3 cases")
    end

    it "check body of the page" do
      body = "for this court room today. Please choose the cases you would like to be part of."
      expect(response.body).to include(body)
    end

    it "check body with matched court case1" do
      expect(response.body).to include("XYZ123")
    end

    it "check body with matched court case2" do
      expect(response.body).to include("XYZ234")
    end

    it "check body with matched court case3" do
      expect(response.body).to include("XYZ345")
    end

    it "check add another case number link" do
      expect(response.body).to include("Add another case number")
    end
  end
end
