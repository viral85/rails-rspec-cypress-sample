module StubRequests
  module_function

  def response_headers
    {
      "Content-Type" => "application/json"
    }
  end

  def stub
    StubRequests::Zoom::OauthToken.new.success
    zoom_meeting_stub = StubRequests::Zoom::Meeting.new
    zoom_meeting_stub.meeting
    zoom_meeting_stub.create_meeting
  end
end
