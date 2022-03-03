module StubRequests
  module Zoom
    class OauthToken
      # TODO
      def initialize; end

      def success
        WebMock.stub_request(:post, "https://zoom.us/oauth/token")
               .with(body: success_params, headers: request_headers)
               .to_return(status: 200, body: success_body.to_json,
                          headers: StubRequests.response_headers)
      end

      def invalid_token
        WebMock.stub_request(:post, "https://zoom.us/oauth/token")
               .with(body: success_params, headers: request_headers)
               .to_return(status: 401, body: invalid_token_response.to_json,
                          headers: StubRequests.response_headers)
      end

      private

      def request_headers
        {
          "Accept" => "*/*",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Content-Type" => "application/x-www-form-urlencoded",
          "User-Agent" => "Faraday v1.7.1"
        }
      end

      def success_params
        {
          "client_id" => nil,
          "client_secret" => nil,
          "grant_type" => "refresh_token",
          "refresh_token" => "REFRESH_TOKEN"
        }
      end

      def success_body
        {
          "access_token" => "access_token",
          "token_type" => "bearer",
          "refresh_token" => "refresh_token",
          "expires_in" => 3599,
          "scope" => "meeting:read meeting:write user:read user:write user_profile"
        }
      end

      def invalid_token_response
        {
          "reason" => "Invalid Token!",
          "error" => "invalid_request"
        }
      end
    end
  end
end
