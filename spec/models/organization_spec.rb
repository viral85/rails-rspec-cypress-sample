require "rails_helper"

RSpec.describe Organization, type: :model do
  subject(:organization) { described_class.new }

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe "associations" do
    it { is_expected.to have_many(:users).dependent(:destroy) }
    it { is_expected.to have_many(:approved_domains).dependent(:destroy) }
  end
end
