require "rails_helper"
require "shared_context/basic_context"

RSpec.describe CourtCase, type: :model do
  include_context "with basic context"

  describe "behaviour" do
    context "when case ended" do
      def create_attendances
        attendance
        create_attendance_record
      end

      before do
        create_attendances
      end

      it "deletes attendaces when ended" do
        expect { court_case.ended! }.to change { court_case.attendances.count }.from(2).to(0)
      end

      it "doesn't delete attendances when started" do
        expect { court_case.active! }.not_to(change { court_case.attendances.count })
      end
    end
  end
end
