class PanelComponentBroadcaster
  delegate :render, to: :ApplicationController

  def initialize(user:, cable_ready:, court_case: nil, participant: nil)
    @court_case = court_case
    @user = user
    @participant = participant
    @shared_panel_token = @user.panel.share_token
    @cable_ready = cable_ready
  end

  protected

  attr_reader :cable_ready

  def broadcast
    cable_ready.broadcast
  end

  def update_cases_counter
    cable_ready["common_panel_changes:#{@user&.id}"].morph(
      children_only: true,
      selector: "#casesTab",
      html: cases_tab_html
    )
  end

  def update_participants_counter
    cable_ready["common_panel_changes:#{@user&.id}"].morph(
      children_only: true,
      selector: "#participantsTab",
      html: participants_tab_html
    )
  end

  def update_autocompletable_cases_data
    cable_ready["host_panel:#{@user&.id}"].morph(
      selector: "#existingCases",
      html: existing_cases_html
    )
  end

  def existing_cases_html
    render(
      partial: "users/panel/panel_components/cases/existing_cases",
      assigns: { court_cases_string: @user.existing_available_cases_string }
    )
  end

  def cases_tab_html
    render(
      partial: "users/panel/panel_components/cases/cases_tab",
      assigns: { user: @user }
    )
  end

  def participants_tab_html
    render(
      partial: "users/panel/panel_components/ungrouped_participants/participants_tab",
      assigns: { user: @user }
    )
  end

  def deactivate_element(selector)
    cable_ready["host_panel:#{@user&.id}"].add_css_class(
      name: %w[opacity-50 deactivated-link],
      select_all: true, selector: selector
    )

    cable_ready["host_panel:#{@user&.id}"].set_attribute(
      name: "disabled", select_all: true, value: "true",
      selector: selector
    )
  end

  def show_element(selector)
    cable_ready["common_panel_changes:#{@user&.id}"].remove_css_class(
      name: %w[hidden], selector: selector
    )
  end

  def hide_element(selector)
    cable_ready["common_panel_changes:#{@user&.id}"].add_css_class(
      name: %w[hidden], selector: selector
    )
  end
end
