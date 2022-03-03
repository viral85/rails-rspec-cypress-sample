require "rails_helper"

RSpec.describe Participant, type: :model do
  subject(:participant) { described_class.new }

  describe "validations" do
    it { is_expected.to validate_presence_of(:first_name) }
  end
end
