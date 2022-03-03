class CreateParticipantService # rubocop:disable Metrics/ClassLength
  attr_reader :error

  def initialize(user:, params:, cookies:, cases:)
    @user = user
    @params = params
    @cookies = cookies
    @cases = cases
    @error = nil
  end

  def call
    if valid_court_cases?
      manage_participant
      @participant
    else
      false
    end
  end

  private

  def manage_participant
    find_participant
    unless @participant_already_created
      initialize_participant
      register_participant_with_zoom_service_call
    end
    return @participant unless @participant.persisted?

    create_attendances if @cases&.size&.positive? && !@participant_already_created
  end

  def register_participant_with_zoom_service_call
    service = RegisterParticipantWithZoomService.new(user: @user, participant: @participant)
    response = service.call
    update_participant(response)
  end

  def participant_first_name
    @cookies[:first_name].presence || @params[:first_name]
  end

  def participant_last_name
    @cookies[:last_name].presence || @params[:last_name]
  end

  def participant_role
    @cookies[:role].presence || @params[:role]
  end

  def participant_locale
    @cookies[:locale].presence || @params[:locale]
  end

  def find_participant
    @participant = Participant.find_by(
      first_name: participant_first_name,
      last_name: participant_last_name,
      role: @role,
      created_at: Time.zone.today.all_day
    )
    @participant_already_created = @participant.nil? ? false : true
  end

  def initialize_participant
    @participant = Participant.new(
      first_name: participant_first_name, last_name: participant_last_name,
      zoom_username: "#{participant_first_name} #{participant_last_name} - #{participant_role}",
      user: @user, zoom_status: "inactive",
      role: participant_role, locale: participant_locale
    )
    @participant.token = Participant.generate_unique_secure_token
    @participant.generate_email
  end

  def update_participant(response)
    @participant.assign_attributes(
      zoom_join_url: response["join_url"],
      zoom_registrant_id: response["registrant_id"]
    )
    @participant.save
  end

  def valid_court_cases?
    # TODO: Define logic
    true
  end

  def case_ended_today?(court_case)
    court_case&.ended? && court_case&.last_meeting_ended_at&.today?
  end

  def set_invalid_case_error
    @error = "We are sorry but it seems that one of the case
    numbers you entered is not valid. Please fix the case number and try again."
  end

  def set_ended_case_error
    @error = "We are sorry but the court case you've registered for has already ended."
    @participant.destroy
  end

  def create_attendances
    @cases.each do |case_input|
      court_case = find_or_create_court_case(case_input)
      if case_ended_today?(court_case)
        create_attendance(nil)
      else
        court_case.pending! if court_case.ended?
        create_attendance(court_case)
      end
    end
  end

  def find_or_create_court_case(case_input)
    CourtCase.find_or_create_by(case_number: case_input, user: @user,
                                organization: @user.organization)
  end

  def create_attendance(court_case)
    Attendance.create(participant: @participant, court_case: court_case, user: @user)
  end
end
