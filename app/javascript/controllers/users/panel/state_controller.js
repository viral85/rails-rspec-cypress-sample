import { Controller } from "stimulus"
import { getConsumerType } from "../../../channels/consumer"

export default class extends Controller {
  static targets = [
    "loader", "controlPanelContent", "messageTitle", "messageDescription", "messageBox"
  ]

  static values = { zoomMeetingTitle: String }

  connect(){
    this.controlPanelContentTarget.classList.add("hidden")
    this.bindListeners()
    this.userType = getConsumerType()
  }

  displayMeetingNotStarted() {
    const description = "To start the control panel please start the Zoom meeting " +
                        `(${this.zoomMeetingTitleValue}). ` +
                        "The control panel should start automatically after the Zoom " +
                        "meeting is started. If it's not, please reload this page. "
    this.displayMessage("Please start the Zoom meeting", description, "notice")
    this.displayStartZoomBtn()
  }

  displayConnectionLost() {
    this.displayMessage("Lost connection",
                         "If this problem persists, please reload or relaunch the control panel")
  }

  displayJoinMeeting() {
    const description = "We are sorry but we have run into an error. " +
                        "Please reload or relaunch the control panel"
    this.displayMessage("Error joining the meeting", description)
  }

  displayMeetingEnded(){
    let description = ""
    if (this.userType == "User") {
      description = "Close the control panel or start the Zoom " +
                    "meeting again if you would like the control panel to restart."
      this.displayStartZoomBtn()
    }
    this.displayMessage("The meeting has ended", description, "notice")
  }

  displayCouldNotStartZoomSDK() {
    this.displayMessage(
      "Could not start Zoom Web SDK",
      "Please contact xyz.io to make sure your account is setup correctly"
    )
  }

  displayHostNotStarted() {
    this.displayMessage("The host hasn't started the meeting yet", "", "notice")
  }

  displayMessage(title, description, type = "error") {
    if (type === "error") {
      this.messageBoxTarget.classList.add("bg-red-50")
      this.messageBoxTarget.classList.remove("bg-blue-50")
      document.getElementById("errorIcon").classList.remove("hidden")
      document.getElementById("noticeIcon").classList.add("hidden")
      this.messageTitleTarget.classList.add("text-red-800")
      this.messageDescriptionTarget.classList.add("text-red-700")
      this.messageTitleTarget.classList.remove("text-blue-800")
      this.messageDescriptionTarget.classList.remove("text-blue-700")
    } else if(type === "notice") {
      this.messageBoxTarget.classList.remove("bg-red-50")
      this.messageBoxTarget.classList.add("bg-blue-50")
      document.getElementById("noticeIcon").classList.remove("hidden")
      document.getElementById("errorIcon").classList.add("hidden")
      this.messageTitleTarget.classList.remove("text-red-800")
      this.messageDescriptionTarget.classList.remove("text-red-700")
      this.messageTitleTarget.classList.add("text-blue-800")
      this.messageDescriptionTarget.classList.add("text-blue-700")
    }
    this.loaderTarget.classList.add("hidden")
    this.controlPanelContentTarget.classList.add("hidden")
    this.messageBoxTarget.classList.remove("hidden")
    this.messageTitleTarget.innerHTML = title
    this.messageDescriptionTarget.innerHTML = description
  }

  displayStartZoomBtn() {
    const startZoomBtn = document.getElementById("startZoomBtn")
    if(startZoomBtn){
      startZoomBtn.classList.remove("hidden")
    }
  }

  bindListeners() {
    this.bindZoomJoinedListener()
    this.bindZoomErrorListener()
    this.bindWebhookSignalListener()
    this.bindDisplayMessage()
  }

  bindDisplayMessage(){
    document.addEventListener("display-couldnt-start-zoom-sdk-message", (e) => {
      this.displayCouldNotStartZoomSDK()
    })

    document.addEventListener("display-meeting-not-started-message", (e) => {
      this.displayMeetingNotStarted()
    })

    document.addEventListener("display-host-not-started-message", (e) => {
      this.displayHostNotStarted()
    })
  }

  bindZoomJoinedListener() {
    document.addEventListener("zoom-joined", (e) => {
      this.setPanelToActiveState()
    })

    document.addEventListener("view-only-panel-available", (e) => {
      this.setPanelToActiveState()
    })
  }

  setPanelToActiveState() {
    this.controlPanelContentTarget.classList.remove("hidden")
    this.loaderTarget.classList.add("hidden")
  }

  bindZoomErrorListener() {
    document.addEventListener("zoom-error", (e) => {
      this.displayJoinMeeting(e.detail.error)
    })
  }

  bindWebhookSignalListener() {
    document.addEventListener("webhook-signal", (e) => {
      const webhook_signal = e.detail
      if (webhook_signal.type == "meeting_started") {
        window.location.reload()
      }
      else if (webhook_signal.type == "meeting_ended") {
        this.displayMeetingEnded()
      }
    })
  }
}
