class RegistrationReflex < ApplicationReflex
  include ::ActionController::Cookies
  before_reflex :set_user

  def validate_case(case_number, case_index)
    if court_case_exists?(case_number)
      valid = true
    else
      valid = validate_service(case_number)
      create_court_case(case_number) if valid
    end
    morph :nothing
    show_validation(valid, case_index)
  end

  private

  def court_case_exists?(case_number)
    @user.organization.court_cases.exists?(case_number: case_number)
  end

  def validate_service(case_number)
    ValidateCaseNumberService.new(
      case_number: case_number,
      organization_domain: @user&.organization&.approved_domains&.first&.domain
    ).call
  end

  def create_court_case(case_number)
    CourtCase.create(
      case_number: case_number,
      user: @user,
      organization: @user.organization
    )
  end

  def show_validation(status, case_index)
    ActionCable.server.broadcast(
      "guest:#{cookies[:xyz_guest_token]}",
      status: status,
      case_index: case_index
    )
  end

  def set_user
    @user = User.find_by(token: params[:id])
  end
end
