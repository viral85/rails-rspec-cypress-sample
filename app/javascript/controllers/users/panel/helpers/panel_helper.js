export default class {
  isParticipantActive(element) {
    return (element.closest(".participant-container").dataset.userActive == "true")
  }

  getZoomUserId(element) {
    return parseInt(element.closest(".participant-container").dataset.zoomUserId)
  }

  zoomSDKHelper() {
    return document.getElementById("control-panel").panelController.zoomSDKHelper
  }
}
