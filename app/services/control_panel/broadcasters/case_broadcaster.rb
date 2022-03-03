class CaseBroadcaster < PanelComponentBroadcaster
  include CaseBroadcasterHelperConcern

  def update_case(court_case, initial_participants_number, initial_meeting_status)
    @court_case = court_case

    if @court_case.active? || initial_meeting_status == "active"
      update_active_case(initial_meeting_status)
    else
      update_upcoming_case(initial_participants_number)
    end
  end

  private

  def update_upcoming_case(initial_participants_number)
    if @court_case.participants.online.count.zero?
      remove_upcoming_case
      update_autocompletable_cases_data
    elsif initial_participants_number.zero?
      insert_upcoming_case
    else
      morph_upcoming_case
    end
    update_cases_state
  end

  def update_active_case(initial_meeting_status)
    if initial_meeting_status == "pending"
      start_case
    else
      morph_active_case
      update_cases_state
    end
    update_autocompletable_cases_data
  end

  def start_case
    remove_upcoming_case
    morph_active_case
    reset_search
    disable_upcoming_cases_start_buttons
  end

  def morph_active_case
    cable_ready["host_panel:#{@user&.id}"].morph(
      children_only: true, selector: "#active-case", html: active_case_html(is_host: true)
    )
    cable_ready["view_only_panel:#{@shared_panel_token}"].morph(
      children_only: true, selector: "#active-case", html: active_case_html(is_host: false)
    )
  end

  def remove_upcoming_case
    cable_ready["host_panel:#{@user&.id}"].remove(
      selector: case_selector, select_all: true
    )
    cable_ready["view_only_panel:#{@shared_panel_token}"].remove(
      selector: case_selector, select_all: true
    )
  end

  def morph_upcoming_case
    cable_ready["host_panel:#{@user&.id}"].morph(
      selector: case_selector, html: upcoming_case_html(is_host: true), select_all: true
    )

    cable_ready["view_only_panel:#{@shared_panel_token}"].morph(
      selector: case_selector, html: upcoming_case_html(is_host: false), select_all: true
    )
  end

  def insert_upcoming_case
    cable_ready["host_panel:#{@user&.id}"].insert_adjacent_html(
      position: "beforeend", selector: "#upcoming-cases",
      html: upcoming_case_html(is_host: true)
    )
    cable_ready["view_only_panel:#{@shared_panel_token}"].insert_adjacent_html(
      position: "beforeend", selector: "#upcoming-cases",
      html: upcoming_case_html(is_host: false)
    )
  end

  def reset_search
    SearchBroadcaster.new(user: @user, cable_ready: cable_ready).reset_search
  end

  def active_case_html(is_host:)
    render(
      partial: "users/panel/panel_components/cases/active_case_component",
      locals: { court_case: @user&.active_case },
      assigns: { user: @user, host_panel: is_host }
    )
  end

  def upcoming_case_html(is_host:)
    render(
      partial: "users/panel/panel_components/cases/case_component",
      locals: { court_case: @court_case }, assigns: { user: @user, host_panel: is_host }
    )
  end

  def case_selector
    "#upcoming-cases #case-#{@court_case.case_number}, #searched-case-#{@court_case.case_number}"
  end
end
