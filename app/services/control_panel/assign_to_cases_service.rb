class AssignToCasesService
  include BroadcasterConcern

  def initialize(case_numbers:, participant:)
    @case_numbers = case_numbers
    @participant = participant
    @user = @participant.user
    @update_sdk_availability_service = UpdateNextSdkAvailabilityService.new(user: @user)
    @attendances = []
    @court_cases = []
  end

  def call
    remove_invalid_numbers
    return if contains_ended_cases?

    update_sdk_availability
    assign_to_cases if @case_numbers.size.positive?
    broadcast_updates
  end

  private

  def assign_to_cases
    @participant.update(zoom_status: :waiting_room)
    create_court_cases
    prepare_broadcast_cargo
    create_attendances
  end

  def contains_ended_cases?
    validate_ended_service = ValidateAssignedCaseNumbersEndedService.new(
      case_numbers: @case_numbers, user: @user, participant_token: @participant.token
    )
    validate_ended_service.call
    validate_ended_service.has_ended_cases
  end

  def update_sdk_availability
    return unless @participant.active?

    @update_sdk_availability_service.call
  end

  def remove_invalid_numbers
    @case_numbers.uniq!
    @case_numbers.reject! { |case_number| case_number if case_number.blank? }
  end

  def create_court_cases
    @case_numbers.each do |case_number|
      next if case_number.blank?

      court_case = find_or_create_case(case_number)
      court_case.update(meeting_status: "pending") if court_case.ended? || court_case.abandoned?
      @court_cases << court_case
    end
  end

  def create_attendances
    @court_cases.each do |court_case|
      @attendances << create_attendance(court_case)
    end
  end

  def find_or_create_case(case_number)
    @user.court_cases.find_or_create_by(case_number: case_number) do |new_court_case|
      new_court_case.user = @user
      new_court_case.organization = @user&.organization
    end
  end

  def create_attendance(court_case)
    Attendance.find_or_create_by(
      user: @user,
      court_case: court_case,
      participant: @participant
    )
  end

  def prepare_broadcast_cargo
    @broadcast_cargo = BroadcastCargo.new(user: @user)
    @court_cases.each do |court_case|
      @broadcast_cargo.capture_court_case(court_case: court_case)
    end
    @broadcast_cargo.capture_ungrouped_participant(participant: @participant)
  end
end
