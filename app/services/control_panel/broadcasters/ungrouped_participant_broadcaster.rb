class UngroupedParticipantBroadcaster < PanelComponentBroadcaster
  def update_ungrouped_participant(participant, initial_court_cases_number, initial_status)
    @participant = participant
    if participant.inactive? || participant.pending_and_active_cases.count.positive?
      remove_ungrouped_participant && update_autocompletable_cases_data
    elsif initial_court_cases_number.positive? || initial_status == "inactive"
      insert_ungrouped_participant
    else
      morph_ungrouped_participant
    end
    update_state
  end

  private

  def morph_ungrouped_participant
    cable_ready["host_panel:#{@user&.id}"].morph(
      permanent_attribute_name: "data-reflex-permanent",
      html: render_participant_html(is_host: true),
      selector: "#ungrouped-participant-#{@participant.token}"
    )

    cable_ready["view_only_panel:#{@shared_panel_token}"].morph(
      permanent_attribute_name: "data-reflex-permanent",
      html: render_participant_html(is_host: false),
      selector: "#ungrouped-participant-#{@participant.token}"
    )
  end

  def insert_ungrouped_participant
    cable_ready["host_panel:#{@user&.id}"].insert_adjacent_html(
      position: "beforeend", selector: "#ungrouped-participants",
      html: participant_html(is_host: true)
    )

    cable_ready["view_only_panel:#{@shared_panel_token}"].insert_adjacent_html(
      position: "beforeend", selector: "#ungrouped-participants",
      html: participant_html(is_host: false)
    )
  end

  def remove_ungrouped_participant
    cable_ready["host_panel:#{@user&.id}"].remove(
      selector: "#ungrouped-participant-#{@participant.token}"
    )

    cable_ready["view_only_panel:#{@shared_panel_token}"].remove(
      selector: "#ungrouped-participant-#{@participant.token}"
    )
  end

  def render_participant_html(is_host:)
    if @participant.active?
      active_participant_html(is_host: is_host)
    else
      participant_html(is_host: is_host)
    end
  end

  def participant_html(is_host:)
    render(
      partial: "users/panel/panel_components/ungrouped_participants/participant",
      locals: { participant: @participant },
      assigns: { user: @user, host_panel: is_host }
    )
  end

  def active_participant_html(is_host:)
    render(
      partial: "users/panel/panel_components/ungrouped_participants/active_participant",
      locals: { participant: @participant },
      assigns: { user: @user, host_panel: is_host }
    )
  end

  def update_ungrouped_participants_visibility
    @user.display_ungrouped_participants? ? show_participants : show_no_participants_message
  end

  def show_participants
    hide_element("#no-participants-message")
    show_element("#ungrouped-participants-content")
  end

  def show_no_participants_message
    show_element("#no-participants-message")
    hide_element("#ungrouped-participants-content")
  end

  def update_state
    update_participants_counter
    update_ungrouped_participants_visibility
  end
end
