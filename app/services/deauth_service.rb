class DeauthService
  def initialize(params:)
    @params = params
    @identity = Identity.find_by(uid: @params["payload"]["user_id"])
    @user = @identity.user
    @meeting = @user.zoom_meeting
  end

  def call
    delete_user_zoom_records
    create_deauth_record
  end

  private

  def delete_user_zoom_records
    @identity&.destroy && @meeting&.destroy
  end

  def create_deauth_record
    deauth_params = @params.to_json
    Deauthorization.create(body: JSON.parse(deauth_params))
  end
end
