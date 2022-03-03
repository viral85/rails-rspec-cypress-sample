namespace :registrant_to_zoom do
  desc "Register all existing participant to zoom"
  task registrant_existing_participant: :environment do
    Attendance.find_each(batch_size: 1) do |attendance|
      register_participant(attendance)
    rescue ActiveRecord::RecordNotFound
      p "Attendance id #{attendance.id} fail"
    rescue StandardError
      p "Attendance id #{attendance.id} fail"
    end
  end

  def register_participant(attendance)
    user = attendance&.user
    participant = attendance&.participant
    return unless user.persisted? && participant.persisted? && !user.zoom_basic_plan?

    service = RegisterParticipantWithZoomService.new(
      user: user, participant: participant
    )
    service.call
  end
end
