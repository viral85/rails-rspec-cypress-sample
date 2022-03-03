module StubRequests
  module Zoom
    class Registrant
      # TODO
      def initialize; end

      def create
        WebMock.stub_request(:post, "https://api.zoom.us/v2/meetings/94446976353/registrants")
               .with(body: regex_body, headers: authorised_headers)
               .to_return(status: 201, body: registrants_body.to_json,
                          headers: StubRequests.response_headers)
      end

      def failure
        WebMock.stub_request(:post, "https://api.zoom.us/v2/meetings/94446976353/registrants")
               .with(body: fail_body, headers: authorised_headers)
               .to_return(status: 400, body: {}.to_json,
                          headers: StubRequests.response_headers)
      end

      private

      def authorised_headers
        {
          "Accept" => "*/*",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Authorization" => "Bearer access_token",
          "Content-Type" => "application/json",
          "User-Agent" => "Ruby"
        }
      end

      def fail_body
        /{"\w{10}":"\w{8}","\w{9}":"Error\s-\s\w{7}","email":"[a-z]+[+]\w{24}@[a-z]+[.][a-z]+"}/
      end

      def regex_body
        /{"first_name":"\w+","last_name":"\w+\s-\s\w+","email":"[a-z]+[+]\w{24}@[a-z]+[.][a-z]+"}/
      end

      def registrants_body
        {
          registrant_id: "jxTLlRDETPONRujxqhC9nA",
          id: 94_446_976_353,
          topic: "Viral Sonawala (Dev)",
          start_time: "2021-08-04T18:30:00Z",
          join_url: "https://zoom.us/w/93685056731?tk=EUTDLxWVgOZvZsSZf8mWPdGjcHxZTW1MtgaxB_Uffsw.DQIAAAAV0BCEvRZqeFRMbFJERVRQT05SdWp4cWhDOW5BAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
        }
      end
    end
  end
end
