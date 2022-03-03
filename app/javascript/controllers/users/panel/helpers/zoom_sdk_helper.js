export default class {
  #ZoomSDK
  #zoomMtg
  sdkLoaded = false
  zoomData

  initializeZoom(zoomDataValue) {
    this.#ZoomSDK = require("@zoomus/websdk")
    this.#zoomMtg = this.#ZoomSDK.ZoomMtg
    this.zoomData = zoomDataValue
    this.initializeZoomMeeting()
  }

  initializeZoomMeeting() {
    let self = this
    const env = document.querySelector("meta[name='env']").content
    const debug = (env == "staging" || env == "development")
    this.#zoomMtg.preLoadWasm()
    this.#zoomMtg.prepareWebSDK()
    this.#zoomMtg.init({
      debug: debug,
      disablePreview: true,
      audioPanelAlwaysOpen: false,
      disableJoinAudio: true,
      disableRecord: true,
      videoHeader: false,
      isSupportAV: false,
      showMeetingHeader: false,
      disableInvite: true,
      disableCallOut: true,
      showPureSharingContent: false,
      isSupportChat: false,
      isSupportQA: false,
      isSupportPolling: false,
      isSupportBreakout: false,
      isSupportCC: false,
      screenShare: false,
      videoDrag: false,
      sharingMode: "fit",
      isSupportNonverbal: false,
      isShowJoiningErrorDialog: false,
      disableCORP: true,
      leaveUrl: self.zoomData.return_url,
      success: function () {
        self.#zoomMtg.join({
          meetingNumber: self.zoomData.meeting_number,
          userName: "xyz.io",
          signature: self.zoomData.signature,
          apiKey: self.zoomData.api_key,
          passWord: self.zoomData.meeting_password,
          success: function() {
            self.cleanUpZoomSDKStyles()
            self.sdkLoaded = true
            document.dispatchEvent(new CustomEvent("zoom-joined"))
          },
          error: function (err) {
            console.log(err)
            self.onError(err)
          }
        })
      },
      error: function (err) {
        console.log(err)
        self.onError(err)
      }
    })
  }

  leaveMeeting(){
    this.#zoomMtg.leaveMeeting({})
  }

  // TODO Generate HB error after 30 secs of load and show error

  onError(error) {
    document.dispatchEvent(new CustomEvent("zoom-error", {
      detail: {
        error: error,
        meetingNumber: this.zoomData.meeting_number
      }
    }))
  }

  cleanUpZoomSDKStyles = function () {
    let styleTags = document.getElementsByTagName("style")
    for (let i = styleTags.length -1; i >=1; --i) { styleTags[i].remove() }
  }

  removeParticipant(zoomUserId) {
    this.#zoomMtg.expel({
      userId: zoomUserId,
      success: function (putonHoldData){
        console.log("success remove")
      },
      error: function (errorRemove){
        console.log(errorRemove)
      }
    })
  }

  admitParticipant(zoomUserId) {
    this.#zoomMtg.putOnHold({
      userId: zoomUserId,
      hold: false,
      success: function (putonHoldData){
        console.log("success admitted")
      },
      error: function (errorPutOnHold){
        console.log(errorPutOnHold)
      }
    })
  }

  putInWaitingRoom(zoomUserId) {
    this.#zoomMtg.putOnHold({
      userId: zoomUserId,
      hold: true,
      success: function (putonHoldData){
        console.log("success put in waiting room")
      },
      error: function (errorPutOnHold){
        console.log(errorPutOnHold)
      }
    })
  }

  renameParticipant(
    { zoomUserId, oldName, newName },
    { participantToken, firstName, lastName, role })
  {
    this.#zoomMtg.rename({
      userId: zoomUserId,
      oldName: oldName,
      newName: newName,
      success: function (renameParticipant){
        console.log("success rename")
        document.dispatchEvent(new CustomEvent("participant-renamed", {
          detail: {
            participantToken: participantToken,
            firstName: firstName,
            lastName: lastName,
            role: role
          }
        }))
      },
      error: function (renameParticipantError){
        console.log(renameParticipantError)
      }
    })
  }
}
