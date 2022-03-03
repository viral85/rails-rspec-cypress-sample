class SearchService
  include CableReady::Broadcaster

  def initialize(search_query:, user:, invited_user_token: nil)
    @user = user
    @search_query = search_query
    @invited_user_token = invited_user_token
    @broadcast_cargo = BroadcastCargo.new(user: @user)
  end

  def filter_upcoming_cases
    filtered_court_cases = @user.search_cases_by_case_number(filter_by: @search_query)

    SearchBroadcaster.new(
      user: @user, search_query: @search_query, cable_ready: cable_ready,
      filtered_court_cases: filtered_court_cases, invited_user_token: @invited_user_token
    ).morph_search_component
    cable_ready.broadcast
  end
end
