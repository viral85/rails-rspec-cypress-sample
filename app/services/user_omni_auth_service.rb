class UserOmniAuthService
  def initialize(auth_hash:)
    @auth_hash = auth_hash
    set_user
  end

  def call
    if @user.persisted?
      create_or_update_identity
      update_user
    else
      find_organization
      create_user_if_valid_org
    end

    create_or_update_zoom_meeting if @user.persisted?

    @user
  end

  private

  def create_or_update_identity # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    identity = @user.identities.find_or_initialize_by(uid: @auth_hash.uid)
    identity.assign_attributes(
      provider: @auth_hash.provider,
      email: @user_email,
      first_name: @auth_hash.extra.raw_info.first_name,
      last_name: @auth_hash.extra.raw_info.last_name,
      account_id: @auth_hash.extra.raw_info.account_id,
      timezone: @auth_hash.extra.raw_info.timezone,
      access_token: @auth_hash.credentials.token,
      refresh_token: @auth_hash.credentials.refresh_token,
      expires_at: @auth_hash.credentials.expires_at,
      personal_meeting_url: @auth_hash.extra.raw_info.personal_meeting_url
    )
    identity.save
  end

  def create_or_update_zoom_meeting
    zoom_meeting_service = SetupZoomMeetingService.new(user: @user)
    zoom_meeting_service.call
  end

  def find_organization
    domain = Mail::Address.new(@user_email).domain
    @organization = ApprovedDomain.find_by(domain: domain)&.organization
  end

  def create_user_if_valid_org
    if @organization && @organization&.within_user_limit?
      create_user
      create_or_update_identity
    elsif @organization&.over_user_limit?
      @user.errors.add(:base, "Your account could not be created. "\
        " Your organization has reached its user limit."\
        " Please contact us at info@xyz.io for more information.")
    else
      @user.errors.add(:base, "We could not find the organization using your email. "\
        "Please contact us at info@xyz.io for more information.")
    end
  end

  def create_user
    @user.assign_attributes(
      first_name: @auth_hash.extra.raw_info.first_name,
      last_name: @auth_hash.extra.raw_info.last_name,
      email: @user_email,
      organization_id: @organization.id,
      zoom_plan: @auth_hash.extra.raw_info.type,
      zoom_cli: user_zoom_cli
    )
    @user.save
  end

  def set_user
    @user_email = @auth_hash&.extra&.raw_info&.email&.downcase
    @user = User.find_or_initialize_by(email: @user_email)
  end

  def update_user
    @user.update(
      first_name: @auth_hash.extra.raw_info.first_name,
      last_name: @auth_hash.extra.raw_info.last_name,
      zoom_plan: @auth_hash.extra.raw_info.type,
      pic_url: @auth_hash.extra.raw_info["pic_url"],
      zoom_cli: user_zoom_cli
    )
  end

  def user_zoom_cli
    custom_attributes = @auth_hash&.extra&.raw_info&.custom_attributes
    custom_attributes&.detect { |attribute| attribute["name"] == "cli" }&.[]("value")
  end
end
