class CreateRegistrantsError < StandardError
  attr_reader :zoom_response

  def initialize(message, response: nil)
    super(message)
    @zoom_response = response
  end
end
