class Panel < ApplicationRecord
  include CableReady::Broadcaster
  has_secure_token :share_token

  belongs_to :user

  def reset_share_token
    broadcast_redirect_no_access
    broadcast_redirect_homepage_no_access
    disconnect_active_invited_users
    reset_active_invited_users_counter
    regenerate_share_token
  end

  def broadcast_redirect_no_access
    ActionCable.server.broadcast(
      "view_only_panel:#{share_token}",
      signal: "redirect_to_no_access_page"
    )
  end

  def broadcast_redirect_homepage_no_access
    ActionCable.server.broadcast(
      "share_view:#{share_token}",
      signal: "redirect_to_no_access_page"
    )
  end

  def disconnect_active_invited_users
    ActionCable.server.remote_connections.where(client: share_token).disconnect
  end

  def disable_sharing
    update(sharing_enabled: false)
    broadcast_redirect_homepage_no_access
    disconnect_active_invited_users
    reset_active_invited_users_counter
  end

  def enable_sharing
    update(sharing_enabled: true)
  end

  def redis_storage
    PanelRedisStorage.new(user_id: user.id, key: "active_invited_users")
  end

  def active_invited_users_count
    redis_storage.get.count
  end

  def active_invited_users_string(count = active_invited_users_count)
    "#{count} secondary #{count > 1 ? 'users are' : 'user is'} currently viewing the control panel"
  end

  def track_active_invited_user(token)
    redis_storage.add token
  end

  def untrack_active_invited_user(token)
    redis_storage.remove token
  end

  def reset_active_invited_users_counter
    redis_storage.delete_all
    broadcast_invited_users_counter_updates
  end

  def broadcast_invited_users_counter_updates
    count = active_invited_users_count
    update_counter_value(user, count)
    update_counter_visibility(user, count)
    cable_ready.broadcast
  end

  def update_counter_value(user, count)
    cable_ready["host_panel:#{user.id}"].text_content(
      selector: "#active_invited_users_counter", text: active_invited_users_string(count)
    )
  end

  def update_counter_visibility(user, count)
    if count.zero?
      cable_ready["host_panel:#{user.id}"].add_css_class(
        selector: "#active_invited_users_container", name: %w[hidden]
      )
    else
      cable_ready["host_panel:#{user.id}"].remove_css_class(
        selector: "#active_invited_users_container", name: %w[hidden]
      )
    end
  end
end
