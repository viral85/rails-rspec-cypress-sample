require "rails_helper"

RSpec.describe "Participants::Registrations.manage_participant", type: :request do
  before do
    StubRequests::Zoom::Registrant.new.create
    create(:organization)
    user = create(:user, first_name: "Jane", last_name: "Dev")
    create(:zoom_meeting, user: user)
    create(:identity, user: user)
  end

  describe "Create participant without case nuber" do
    before do
      params = { "button-b" => "I don't know my case number",
                 participant: { first_name: "Dev", last_name: "Thomas", role: "Witness" } }
      post manage_participant_path("123456"), params: params
    end

    it "redirects to meeting link page" do
      expect(response).to redirect_to(meeting_link_path(123_456))
    end

    it "creates a participant record" do
      expect(Participant.count).to eq(1)
    end

    it "not creates a attendance record" do
      expect(Attendance.count).to eq(0)
    end
  end

  describe "Create participant with multiple attendances" do
    before do
      court_cases_attributes = { 0 => { _destroy: false, case_number: "ABC123" },
                                 1 => { _destroy: false, case_number: "XYZ123" } }
      params = { participant: { first_name: "Dev", last_name: "Thomas", role: "Witness",
                                court_cases_attributes: court_cases_attributes } }
      post manage_participant_path("123456"), params: params
    end

    it "redirects to meeting link page" do
      expect(response).to redirect_to(meeting_link_path(123_456))
    end

    it "creates participant record" do
      expect(Participant.count).to eq(1)
    end

    it "creates two attendaces record" do
      expect(Attendance.count).to eq(2)
    end

    it "creates two participantAttendancesHistory record" do
      expect(ParticipantAttendancesHistory.count).to eq(2)
    end
  end

  describe "Create participant with single attences" do
    before do
      court_cases_attributes = { 0 => { _destroy: false, case_number: "ABC123" } }
      params = { participant: { first_name: "Dev", last_name: "Thomas", role: "Witness",
                                court_cases_attributes: court_cases_attributes } }
      post manage_participant_path("123456"), params: params
    end

    it "redirects to meeting link page" do
      expect(response).to redirect_to(meeting_link_path(123_456))
    end

    it "creates a participant record" do
      expect(Participant.count).to eq(1)
    end

    it "creates a attendances record" do
      expect(Attendance.count).to eq(1)
    end

    it "creates a participantAttendancesHistory record" do
      expect(ParticipantAttendancesHistory.count).to eq(1)
    end
  end
end
