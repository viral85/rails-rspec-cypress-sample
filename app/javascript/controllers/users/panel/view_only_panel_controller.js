import { Controller } from "stimulus"

import { subscribeViewOnlyPanel } from "../../../channels/users/view_only_panel_channel"
import { subscribeIndividualViewOnlyPanel } from
  "../../../channels/users/individual_view_only_panel_channel"
import { subscribeCommonPanelChanges } from "../../../channels/users/common_panel_changes_channel"

export default class extends Controller {
  static values = { zoomMeetingStatus: String }

  connect() {
    this.initializeControlPanel()
  }

  initializeControlPanel() {
    subscribeViewOnlyPanel()
    subscribeIndividualViewOnlyPanel()
    subscribeCommonPanelChanges()

    if (this.zoomMeetingStatusValue == "started") {
      document.dispatchEvent(new CustomEvent("view-only-panel-available"))
    } else {
      document.dispatchEvent(new CustomEvent("display-host-not-started-message"))
    }
  }
}
