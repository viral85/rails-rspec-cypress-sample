authorised_headers =
  {
    "Accept" => "*/*",
    "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
    "Authorization" => "Bearer access_token",
    "Content-Type" => "application/json",
    "User-Agent" => "Ruby"
  }

meeting_response_body =
  {
    id: "94446976353",
    uuid: "9ByocNJ/RL2kc/uvZ0g64Q==",
    topic: "Jane Dev",
    join_url: "join url",
    registration_url: "sample_registration_url",
    password: "sdsd",
    type: 8,
    recurrence: { "end_date_time" => 30.days.from_now },
    occurrences: [{ occurrence_id: 123_123 }]
  }

WebMock.stub_request(:get, "https://api.zoom.us/v2/meetings/94446976353")
       .with(headers: authorised_headers)
       .to_return(status: 200, body: meeting_response_body.to_json,
                  headers: { "Content-Type" => "application/json" })
