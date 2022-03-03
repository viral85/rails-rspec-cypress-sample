class SearchCourtCasesService
  include ::ActionController::Cookies
  attr_accessor :participant

  def initialize(params:)
    @params = params
    @participant = "#{@params[:first_name]} #{@params[:last_name]}"
  end

  def call
    cases_from_name
  end

  private

  def cases_from_name
    if @participant == "Elon Musk" && @params[:role] != "Lawyer"
      single_case
    elsif @participant == "John Smith" && @params[:role].include?("attorney")
      multiple_cases
    else
      false
    end
  end

  def single_case
    ["XYZ123"]
  end

  def multiple_cases
    %w[XYZ123 XYZ234 XYZ345]
  end
end
