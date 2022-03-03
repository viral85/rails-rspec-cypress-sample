class Identity < ApplicationRecord
  # Associations
  belongs_to :user

  # Enums
  enum provider: { zoom: 0 }

  # Callbacks
  after_update :update_user_attributes
  after_create :identify_in_segment

  # Methods
  def updated_access_token
    token = oauth_token
    token.expired? ? refresh_access_token(token) : access_token
  end

  def update_user_attributes
    user.update_identity_attributes
  end

  private

  def zoom_oauth_client
    OAuth2::Client.new(
      Rails.application.credentials.zoom[:app_key],
      Rails.application.credentials.zoom[:app_secret],
      site: "https://zoom.us",
      authorize_url: "/oauth/authorize",
      token_url: "/oauth/token"
    )
  end

  def oauth_token
    OAuth2::AccessToken.new(
      zoom_oauth_client,
      access_token,
      { refresh_token: refresh_token, expires_at: expires_at }
    )
  end

  def refresh_access_token(token)
    new_token = token.refresh!

    return if new_token.blank?

    update(
      access_token: new_token.token,
      expires_at: new_token.expires_at,
      refresh_token: new_token.refresh_token
    )

    new_token.token
  end

  def identify_in_segment
    event = { "type": "identify" }
    SegmentWorker.perform_async(user.id, event)
  end
end
