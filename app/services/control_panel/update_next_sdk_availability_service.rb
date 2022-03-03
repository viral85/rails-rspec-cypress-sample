class UpdateNextSdkAvailabilityService
  include CableReady::Broadcaster

  def initialize(user:, court_case: nil)
    @user = user
    @court_case = court_case
    @zoom_processing_duration = 1.6
  end

  def call(zoom_processing_duration: nil)
    @zoom_processing_duration = zoom_processing_duration if zoom_processing_duration.present?

    if batch_update?
      update_next_sdk_request_availability_batch
    else
      update_next_sdk_request_availability
    end
    rerender_availability_element
  end

  private

  def batch_update?
    @court_case.present?
  end

  def rerender_availability_element
    cable_ready["host_panel:#{@user.id}"].morph(
      children_only: true,
      selector: "#controlPanelElementsAvailabilityContainer",
      html: render_availability_component
    ).broadcast
  end

  def update_next_sdk_request_availability
    available_at = Time.zone.now + @zoom_processing_duration.seconds
    update_availability(available_at)
  end

  def update_next_sdk_request_availability_batch
    seconds = @zoom_processing_duration.seconds * @court_case.active_participants_count
    available_at = Time.zone.now + seconds
    update_availability(available_at)
  end

  def update_availability(available_at)
    @user.update(next_zoom_sdk_request_available_at: available_at)
  end

  def render_availability_component
    ApplicationController.render(
      partial: "users/panel/panel_components/availability_component",
      assigns: { user: @user }
    )
  end
end
