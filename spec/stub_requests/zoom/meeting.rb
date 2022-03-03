module StubRequests
  module Zoom
    class Meeting
      # TODO
      def initialize; end

      def meeting
        WebMock.stub_request(:get, "https://api.zoom.us/v2/meetings/94446976353")
               .with(headers: authorised_headers)
               .to_return(status: 200, body: meeting_response_body.to_json,
                          headers: StubRequests.response_headers)
      end

      def create_meeting
        WebMock.stub_request(:post, "https://api.zoom.us/v2/users/KdYKjnimT4KPd8FFgQt9FQ/meetings")
               .with(body: meeting_request_body, headers: StubRequests.response_headers)
               .to_return(status: 200, body: meeting_response_body.to_json,
                          headers: StubRequests.response_headers)
      end

      def meeting_with_registration_disabled
        WebMock.stub_request(:get, "https://api.zoom.us/v2/meetings/94446976353")
               .with(headers: authorised_headers)
               .to_return(status: 200, body: registration_disable_meeting.to_json,
                          headers: StubRequests.response_headers)
      end

      private

      def meeting_request_body
        start_time = Time.zone.now.beginning_of_day
        end_time = (start_time + 30.days + 8.hours).strftime("%Y-%m-%dT%H:%M:%SZ")
        start_time = start_time.strftime("%Y-%m-%dT%H:%M:%S")
        "{\"topic\":\"Jane Dev\",\"type\":8,\"settings\":" \
          "{\"host_video\":false,\"participant_video\":false,\"mute_upon_entry\":true," \
          "\"approval_type\":0,\"registration_type\":2,\"audio\":\"both\"," \
          "\"close_registration\":true,\"waiting_room\":true,\"allow_multiple_devices\":false," \
          "\"registrants_email_notification\":false}," \
          "\"recurrence\":{\"type\":1,\"repeat_interval\":1,\"end_date_time\":\"#{end_time}\"}" \
          ",\"start_time\":\"#{start_time}\",\"duration\":1440}"
      end

      def authorised_headers
        {
          "Accept" => "*/*",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Authorization" => "Bearer access_token",
          "Content-Type" => "application/json",
          "User-Agent" => "Ruby"
        }
      end

      def meeting_response_body
        {
          id: "94446976353",
          uuid: "9ByocNJ/RL2kc/uvZ0g64Q==",
          topic: "Jane Dev", join_url: "join url",
          registration_url: "https://zoom.us/sample_registration_url",
          password: "sdsd",
          type: 8,
          recurrence: { end_date_time: 30.days.from_now },
          occurrences: [{ occurrence_id: 123_123 }]
        }
      end

      def registration_disable_meeting
        {
          id: "94446976353",
          uuid: "9ByocNJ/RL2kc/uvZ0g64Q==",
          topic: "Jane Dev", join_url: "join url",
          password: "sdsd",
          type: 8,
          recurrence: { end_date_time: 30.days.from_now }
        }
      end
    end
  end
end
