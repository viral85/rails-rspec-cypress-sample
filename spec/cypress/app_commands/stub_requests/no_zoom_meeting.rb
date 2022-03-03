authorised_headers =
  {
    "Accept" => "*/*",
    "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
    "Authorization" => "Bearer access_token",
    "Content-Type" => "application/json",
    "User-Agent" => "Ruby"
  }

response_body =
  {
    code: 3001,
    message: "Meeting 12345678912 is not found or has expired."
  }

WebMock.stub_request(:get, "https://api.zoom.us/v2/meetings/94446976353")
       .with(headers: authorised_headers)
       .to_return(status: 404, body: response_body.to_json,
                  headers: { "Content-Type" => "application/json" })
