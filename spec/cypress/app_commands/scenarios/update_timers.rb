Participant.all.each { |p| p.update(entered_waiting_room_at: Time.zone.now - 5.minutes) }
CourtCase.active.first.update(started_at: Time.zone.now - 5.minutes)
