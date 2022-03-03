module ZoomWebhookUsernameConcern
  extend ActiveSupport::Concern

  private

  def extract_first_name
    username_without_role&.split(" ", 2)&.first
  end

  def extract_last_name
    username_without_role&.split(" ", 2)&.second || ""
  end

  def extract_role
    payload_username.split(" - ").last if username_contains_role?
  end

  def username_without_role
    if username_contains_role?
      payload_username.split(" - ")[0..-2].join(" - ")
    else
      payload_username
    end
  end

  def username_contains_role?
    payload_username.include?(" - ")
  end

  def name_changed?
    username_without_role.strip != @participant.full_name.strip
  end

  def role_changed?
    @participant.role != extract_role
  end
end
