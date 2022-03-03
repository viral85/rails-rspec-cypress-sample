class ValidateAssignedCaseNumbersEndedService
  include CableReady::Broadcaster

  attr_accessor :has_ended_cases

  def initialize(case_numbers:, user:, participant_token:)
    @case_numbers = case_numbers
    @user = user
    @participant_token = participant_token
    @ended_today_cases_indexes = []
    @has_ended_cases = false
  end

  def call
    set_ended_cases_indexes

    @ended_today_cases_indexes.each do |case_input_index|
      @has_ended_cases = true
      show_error_label(case_input_index)
      disable_assign_btn
      cable_ready.broadcast
    end
  end

  private

  def show_error_label(case_input_index)
    cable_ready["host_panel:#{@user&.id}"].remove_css_class(
      name: "hidden",
      selector: "#case-index-#{@participant_token}-#{case_input_index} .input-error-case-ended"
    )
  end

  def disable_assign_btn
    cable_ready["host_panel:#{@user&.id}"].add_css_class(
      name: "opacity-50",
      selector: "#assign-btn-#{@participant_token}"
    )
    cable_ready["host_panel:#{@user&.id}"].set_attribute(
      name: "disabled",
      value: true,
      selector: "#assign-btn-#{@participant_token}"
    )
  end

  def set_ended_cases_indexes
    @case_numbers.each_with_index do |case_number, index|
      court_case = @user.court_cases.find_by(case_number: case_number)
      @ended_today_cases_indexes << index if court_case&.last_meeting_ended_at&.today?
    end
  end
end
