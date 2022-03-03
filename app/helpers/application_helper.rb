module ApplicationHelper
  def page_is_host_panel?
    action_name == "panel"
  end

  def page_is_view_only_panel?
    action_name == "view_only_panel"
  end

  def host_panel?
    @host_panel ||= false
  end

  def load_analytics?
    segment_enabled?
  end

  def load_segment?(participant_page)
    segment_enabled? && (user_signed_in? || invitor_user) && participant_page != true
  end

  def invitor_user
    invitor_token = cookies[:xyz_invitor_token]
    return nil if invitor_token.blank?

    User.includes(:panel).where(panel: { share_token: invitor_token }).first
  end

  def current_analytics_user
    current_user || invitor_user
  end

  private

  def segment_enabled?
    AppConfigurations.segment_enabled?
  end
end
