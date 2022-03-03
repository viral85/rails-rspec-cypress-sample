require "rails_helper"
require "shared_context/basic_context"

RSpec.describe Attendance, type: :model do
  include_context "with basic context"

  describe "behaviour" do
    context "with logging participants history" do
      let(:expected_values_for_participant_attendances_history) do
        {
          first_name: participant.first_name,
          last_name: participant.last_name,
          court_case_number: court_case.case_number
        }
      end

      def create_attendance
        attendance
      end

      it "creates Participant Attendance History record on every new attendance" do
        expect { create_attendance }.to change { ParticipantAttendancesHistory.all.count }.from(0).to(1)
      end

      it "saves Participant details into Participant Attendance History" do
        create_attendance
        expect(ParticipantAttendancesHistory.last).to have_attributes(
          expected_values_for_participant_attendances_history
        )
      end
    end
  end
end
