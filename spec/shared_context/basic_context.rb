RSpec.configure do |rspec|
  rspec.shared_context_metadata_behavior = :apply_to_host_groups
end

RSpec.shared_context "with basic context", shared_context: :metadata do
  let(:organization) { FactoryBot.create(:organization_with_approved_domain) }
  let(:user) { FactoryBot.create(:user, organization: organization) }
  let(:court_case) { FactoryBot.create(:court_case, user: user, organization: organization) }
  let(:participant) { FactoryBot.create(:participant, user: user) }
  let(:attendance) do
    create_attendance_record
  end

  def create_attendance_record
    FactoryBot.create(
      :attendance, participant: participant, court_case: court_case, user: user
    )
  end
end

RSpec.configure do |rspec|
  rspec.include_context "with basic context", include_shared: true
end
