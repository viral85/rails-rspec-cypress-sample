class ValidateCaseNumberService
  def initialize(case_number:, organization_domain:)
    @case_number = case_number
    @organization_domain = organization_domain
  end

  def call
    validate_case
  end

  private

  def validate_case
    # TODO: hit the CMS API endpoint
    @case_number != "ABC1234" && @case_number != ""
  end
end
