module CaseBroadcasterHelperConcern
  extend ActiveSupport::Concern

  private

  def disable_upcoming_cases_start_buttons
    deactivate_element("#upcoming-cases .start-btn")
  end

  def show_upcoming_cases_label
    show_element("#upcoming-cases-label")
  end

  def hide_upcoming_cases_label
    hide_element("#upcoming-cases-label")
  end

  def show_cases
    hide_element("#no-cases-message")
    show_element("#cases-content")
  end

  def show_no_cases_message
    show_element("#no-cases-message")
    hide_element("#cases-content")
  end

  def update_cases_state
    update_cases_counter
    update_cases_visibility
  end

  def update_cases_visibility
    if @user.display_cases?
      show_cases
      if @user.pending_cases_with_active_participants.empty?
        hide_upcoming_cases_label
      else
        show_upcoming_cases_label
      end
    else
      show_no_cases_message
    end
  end
end
