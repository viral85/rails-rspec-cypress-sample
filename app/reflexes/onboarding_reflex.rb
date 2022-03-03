class OnboardingReflex < ApplicationReflex
  def complete_step
    case step_number
    when "1"
      current_user.onboarding.update(completed_step1: true)
    when "2"
      current_user.onboarding.update(completed_step2: true)
    when "3"
      current_user.onboarding.update(completed_step3: true)
    end
    send_completed_step_to_segment
  end

  private

  def step_number
    element.dataset[:step_number]
  end

  def send_completed_step_to_segment
    event = {
      "type": "track",
      "title": "Completed Onboarding Step #{step_number}"
    }
    SegmentWorker.perform_async(current_user.id, event)
  end
end
