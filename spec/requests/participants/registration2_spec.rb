require "rails_helper"

RSpec.describe "Participants::Registrations", type: :request do
  before do
    StubRequests::Zoom::Registrant.new.create
    create(:organization)
    user = create(:user, first_name: "Jane", last_name: "Dev")
    create(:zoom_meeting, user: user)
    create(:identity, user: user)
  end

  describe "No case number match and redirect to case registration page" do
    before do
      params = {
        participant: {
          first_name: "Dev", last_name: "Thomas",
          role: "Witness", locale: "en"
        }
      }
      post participants_path("123456"), params: params
    end

    it "redirects to registration cases page" do
      expect(response).to redirect_to(registration_cases_path(123_456))
    end
  end

  describe "Not match a case number bases on first nama and last name" do
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

    it "check no matches found" do
      expect(response.body).to include("No matches found")
    end

    it "check no matches body text" do
      body = "Hi Dev Thomas, we could not match any cases to your name. "
      body += "If you know your case number, "
      body += "please add it below. Otherwise, proceed by "
      body += "clicking the \"I don't know my case number\" button."
      expect(response.body).to include(body)
    end

    it "check add another case number link" do
      expect(response.body).to include("Add another case number")
    end

    it "check I don't know my case number button" do
      expect(response.body).to include("I don't know my case number")
    end

    it "check Register button" do
      expect(response.body).to include("Register")
    end
  end
end
