class BroadcastCargo
  attr_reader :cases_packages, :ungrouped_participants_packages, :search_package

  def initialize(user:)
    @user = user
    @cases_packages = []
    @ungrouped_participants_packages = []
  end

  def capture_involved_cases_for(participants)
    participants = participants.online if participants.count > 1
    involved_participants_ids = participants.pluck(:id)
    captured_cases = @user.court_cases.not_ended_today
                          .joins(:attendances)
                          .where(attendances: { participant_id: [involved_participants_ids] })
                          .distinct
    captured_cases.each { |court_case| capture_court_case(court_case: court_case) }
  end

  def capture_court_case(court_case:)
    @cases_packages << {
      court_case_id: court_case.id,
      initial_participants_number: court_case.participants.online.count,
      initial_meeting_status: court_case.meeting_status
    }
  end

  def capture_ungrouped_participant(participant:)
    @ungrouped_participants_packages << {
      ungrouped_participant_id: participant.id,
      initial_court_cases_number: participant.pending_and_active_cases.count,
      initial_status: participant.zoom_status
    }
  end

  def capture_search_request(search_query, filtered_court_cases)
    @search_package = {
      search_query: search_query,
      filtered_court_cases: filtered_court_cases
    }
  end
end
