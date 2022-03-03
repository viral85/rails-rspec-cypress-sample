export default class {
  #ZoomSDK
  #zoomMtg
  sdkLoaded = false
  zoomData

  initializeZoom(zoomDataValue) {
    this.initializeZoomMeeting()
  }

  initializeZoomMeeting() {
    this.sdkLoaded = true
    document.dispatchEvent(new CustomEvent("zoom-joined"))
  }

  removeParticipant(zoomUserId) {}

  admitParticipant(zoomUserId) {}

  putInWaitingRoom(zoomUserId) {}

  renameParticipant({zoomUserId, oldName, newName}) {}

  leaveMeeting(){}
}
