class SearchBroadcaster
  delegate :render, to: :ApplicationController

  def initialize(
    user:, cable_ready:, search_query: nil, filtered_court_cases: [], invited_user_token: nil
  )
    @user = user
    @invited_user_token = invited_user_token
    @search_query = search_query
    @filtered_court_cases = filtered_court_cases
    @cable_ready = cable_ready
  end

  def morph_search_component
    cable_ready[receiver_channel].morph(
      children_only: true, selector: "#search-results", html: search_component_html
    )
  end

  def clear_search_input
    cable_ready[receiver_channel].morph(
      children_only: true, selector: "#search-field-block", html: search_field_html
    )
  end

  def reset_search
    clear_search_input
    morph_search_component
  end

  private

  attr_reader :cable_ready

  def search_component_html
    render(
      partial: "users/panel/panel_components/cases/searched_cases_component",
      locals: { search_query: @search_query, filtered_court_cases: @filtered_court_cases },
      assigns: { user: @user, searched: true, host_panel: host_search? }
    )
  end

  def search_field_html
    render(
      partial: "users/panel/panel_components/cases/search_field_component",
      locals: { search_query: @search_query }
    )
  end

  def receiver_channel
    if host_search?
      "host_panel:#{@user&.id}"
    else
      "individual_view_only_panel:#{@invited_user_token}"
    end
  end

  def host_search?
    @invited_user_token.blank?
  end
end
