class SettingsReflex < ApplicationReflex
  def save_role(role_obj)
    @role_obj = role_obj
    @role_obj = @role_obj.transform_keys { |key| key.to_s.underscore }
    role = UserRole.find(@role_obj["role_id"])
    return if role.update(text: @role_obj["text"], spanish_text: @role_obj["spanish_text"])

    morph "#role-error-#{role&.id}", role.errors[:text]&.first
  end

  def create_role(role_obj)
    role_obj = role_obj.transform_keys { |key| key.to_s.underscore }
    role = current_user.user_roles.create(text: role_obj["text"],
                                          spanish_text: role_obj["spanish_text"])
    if role.persisted?
      render_new_role
    else
      morph "#role-error-#{role&.id}", role.errors[:text]&.first
    end
  end

  def delete_role(role_id)
    @role = UserRole.find(role_id)
    @role.destroy
  end

  def update_list(element_id, position)
    @role = UserRole.find(element_id)
    @role.update(position: position)

    morph :nothing
  end

  def save_topic(topic_name)
    @topic_name = topic_name
    @zoom_meeting = current_user.zoom_meeting
    response = EditZoomMeetingService.new(user: current_user, params: new_topic_params).call
    if response.code == 204 && topic_name != ""
      @zoom_meeting.update(topic: topic_name)
    else
      @request_error = "There was an error with this request"
    end
  end

  private

  def render_new_role
    roles = current_user.user_roles.order(position: :asc)
    empty_role = render(partial: "users/pages/settings_components/role",
                        locals: { role: current_user.user_roles.build, new_role: true })
    role_list = render(partial: "users/pages/settings_components/role_list",
                       locals: { roles: roles })
    morph "#new-role-list", empty_role
    morph "#role-list", role_list
  end

  def new_topic_params
    {
      topic: @topic_name
    }
  end
end
