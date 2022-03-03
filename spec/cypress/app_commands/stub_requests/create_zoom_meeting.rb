authorised_headers =
  {
    "Accept" => "*/*",
    "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
    "Authorization" => "Bearer access_token",
    "Content-Type" => "application/json",
    "User-Agent" => "Ruby"
  }

start_time = Time.zone.now.beginning_of_day
end_time = (start_time + 30.days + 8.hours).strftime("%Y-%m-%dT%H:%M:%SZ")
start_time = start_time.strftime("%Y-%m-%dT%H:%M:%S")

body =
  {
    "topic" => "Firstname Lastname",
    "type" => 8,
    "settings" => {
      "host_video" => false,
      "participant_video" => false,
      "mute_upon_entry" => true,
      "approval_type" => 0,
      "registration_type" => 2,
      "audio" => "both",
      "close_registration" => true,
      "waiting_room" => true,
      "allow_multiple_devices" => false,
      "registrants_email_notification" => false
    },
    "recurrence" => {
      "type" => 1,
      "repeat_interval" => 1,
      "end_date_time" => end_time.to_s
    },
    "start_time" => start_time.to_s,
    "duration" => 1440
  }

meeting_response_body =
  {
    "id" => "94446976353",
    "uuid" => "9ByocNJ/RL2kc/uvZ0g64Q==",
    "topic" => "Firstname Lastname",
    "join_url" => "join url",
    "password" => "sdsd",
    "type" => 8,
    "recurrence" => { "end_date_time" => 30.days.from_now }
  }

WebMock.stub_request(:post, "https://api.zoom.us/v2/users/KdYKjnimT4KPd8FFgQt9FQ/meetings")
       .with(headers: authorised_headers, body: body.to_json)
       .to_return(status: 200, body: meeting_response_body.to_json,
                  headers: { "Content-Type" => "application/json" })

WebMock.stub_request(:get, "https://api.zoom.us/v2/meetings/94446976353")
       .with(headers: authorised_headers)
       .to_return(status: 200, body: meeting_response_body.to_json,
                  headers: { "Content-Type" => "application/json" })
