User.last.participants.where(zoom_status: "loading_state").update(zoom_status: "meeting_room")
