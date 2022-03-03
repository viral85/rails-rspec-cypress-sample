module OmniauthMacros
  def zoom_hash # rubocop:disable Metrics/MethodLength
    OmniAuth.config.mock_auth[:zoom] = OmniAuth::AuthHash.new(
      {
        "provider": "zoom",
        "uid": "KdYKjnimT4KPd8FFgQt9FQ",
        "credentials": credentials,
        "extra": {
          "raw_info": {
            "first_name": "Jane",
            "last_name": "Dev",
            "email": "user@acme.com",
            "type": 2,
            "personal_meeting_url": "https://janedevinc.zoom.us/j/1234567890",
            "timezone": "America/Denver",
            "verified": 1,
            "host_key": "533895",
            "im_group_ids": ["3NXCD9VFTCOUH8LD-QciGw"],
            "account_id": "gVcjZnYYRLDbb_MfgHuaxg",
            "language": "en-US",
            "phone_country": "US",
            "phone_number": "+1 1234567891",
            "status": "active"
          }
        }
      }
    )
  end

  def zoom_organization_error # rubocop:disable Metrics/MethodLength
    OmniAuth.config.mock_auth[:zoom] = OmniAuth::AuthHash.new(
      {
        "provider": "zoom",
        "uid": "KdYKjnimT4KPd8FFgQt9FQ",
        "credentials": credentials,
        "extra": {
          "raw_info": {
            "id": "KdYKjnimT4KPd8FFgQt9FQ",
            "first_name": "Jane",
            "last_name": "Dev",
            "email": "user@acm.com"
          }
        }
      }
    )
  end

  private

  def credentials
    {
      "token": "ACCESS_TOKEN",
      "refresh_token": "REFRESH_TOKEN",
      "expires_at": 1_594_035_991,
      "expires": true
    }
  end
end
