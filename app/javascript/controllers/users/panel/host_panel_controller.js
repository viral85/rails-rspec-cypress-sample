import { Controller } from "stimulus"
import StimulusReflex from "stimulus_reflex"

import { subscribeHostPanel } from "../../../channels/users/host_panel_channel"
import { subscribeCommonPanelChanges } from "../../../channels/users/common_panel_changes_channel"
import TestMockZoomSDKHelper from "./helpers/test_mock_zoom_sdk_helper"

export default class extends Controller {
  static values = { zoomData: Object, zoomMeetingStatus: String }

  env = document.querySelector("meta[name='env']").content

  zoomSDKHelper
  connect() {
    this.element["panelController"] = this
    // this.controlPanelContentTarget.classList.add("hidden")
    this.bindListeners()
    this.importLottie()
    subscribeHostPanel()
    subscribeCommonPanelChanges()
    this.initializeControlPanel()
  }

  initializeControlPanel() {
    if (this.env == "test") {
      this.zoomSDKHelper = new TestMockZoomSDKHelper
      this.launchControlPanel()
    }
    else if (this.isZoomDataEmpty()) {
      document.dispatchEvent(new CustomEvent("display-couldnt-start-zoom-sdk-message"))
    } else if (this.zoomMeetingStatusValue == "started") {
      import("./helpers/zoom_sdk_helper").then((ZoomSDKHelperModule) => {
        this.zoomSDKHelper = new ZoomSDKHelperModule.default
        this.launchControlPanel()
      })
    } else {
      document.dispatchEvent(new CustomEvent("display-meeting-not-started-message"))
    }
  }

  isZoomDataEmpty() {
    return Object.keys(this.zoomDataValue).length == 0
  }

  importLottie() {
    import("@lottiefiles/lottie-player")
  }

  launchControlPanel() {
    this.zoomSDKHelper.initializeZoom(this.zoomDataValue)
    StimulusReflex.register(this)

    this.setCloseWindowEvent()
  }

  setCloseWindowEvent(){
    window.addEventListener("beforeunload", (event) => {
      this.zoomSDKHelper.leaveMeeting()
    })
  }

  bindListeners() {
    this.bindParticipantRenamedListener()
  }

  bindParticipantRenamedListener() {
    document.addEventListener("participant-renamed", (e) => {
      const participantToken = e.detail.participantToken
      const firstName = e.detail.firstName
      const lastName = e.detail.lastName
      const role = e.detail.role
      this.stimulate("PanelReflex#update_participant", participantToken, firstName, lastName, role)
    })
  }

  toggleViewCasesParticipants() {
    this.stimulate("PanelReflex#toggle_view_case_paricipants", event.currentTarget)
  }
}
