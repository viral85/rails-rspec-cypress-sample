class GenerateDevDataService
  def initialize(user_id: nil)
    setup_org
    setup_user(user_id)
  end

  def generate_case_with_participants(number_of_participants: 3, case_number: nil)
    court_case = CourtCase.create(user: @user, organization: @organization,
                                  case_number: case_number || "B000#{Faker::Code.asin.last(4)}")
    number_of_participants.times do
      participant = Participant.create!(
        first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, user: @user,
        role: @role, zoom_status: "waiting_room", entered_waiting_room_at: Time.now.utc
      )
      court_case.attendances.create(participant: participant, user: @user)
    end
  end

  def generate_participant_without_case(first_name:, last_name:)
    first_name ||= Faker::Name.first_name
    last_name ||= Faker::Name.last_name

    Participant.create!(
      first_name: first_name, last_name: last_name, user: @user, zoom_status: "waiting_room",
      entered_waiting_room_at: Time.zone.now
    )
  end

  def generate_participants_without_case(number_of_participants: nil)
    number_of_participants ||= 3
    number_of_participants.times do
      Participant.create!(
        first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, user: @user,
        zoom_status: "waiting_room", role: @role, entered_waiting_room_at: Time.zone.now
      )
    end
  end

  def clear_court_cases_and_participants
    CourtCase.all.destroy_all
    Participant.all.destroy_all
  end

  private

  def setup_org
    @organization = Organization.first ||
                    Organization.create(
                      name: Faker::Company.name
                    )
    setup_roles(@organization)
    ApprovedDomain.create(domain: "localhost:3000", organization: @organization)
  end

  def setup_roles(org)
    ["Prosecuting Attorney", "Defense Attorney", "Witness"].each do |role|
      OrganizationRole.create(organization: org, text: role)
    end
  end

  def setup_user(user_id)
    @user = User.find_by(id: user_id) || User.last ||
            User.create(
              email: Faker::Internet.email,
              first_name: Faker::Name.first_name,
              last_name: Faker::Name.last_name
            )
    @role = @user&.organization&.organization_roles&.sample&.text
  end
end
