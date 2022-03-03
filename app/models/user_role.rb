class UserRole < ApplicationRecord
  attr_accessor :skip_tracking

  belongs_to :user

  acts_as_list scope: :user

  validates :text, uniqueness: { scope: :user_id, message: "Role should be unique" }

  # Callbacks
  after_create :track_new_role_in_segment, unless: proc { skip_tracking }
  after_destroy :track_deleted_role_in_segment
  before_update :track_update_in_segment, if: :will_save_change_to_text?
  before_update :track_update_in_segment, if: :will_save_change_to_spanish_text?

  def track_event(properties)
    event = {
      "type": "track",
      "title": "Modified Role",
      "properties": properties
    }
    SegmentWorker.perform_async(user_id, event)
  end

  def track_update_in_segment
    properties = {
      old_role: text_was, new_role: text,
      old_spanish_role: spanish_text_was, new_spanish_role: spanish_text
    }
    track_event(properties)
  end

  def track_new_role_in_segment
    properties = { role_added: text, spanish_role_added: spanish_text }
    track_event(properties)
  end

  def track_deleted_role_in_segment
    properties = { role_deleted: text, spanish_role_deleted: spanish_text }
    track_event(properties)
  end
end
