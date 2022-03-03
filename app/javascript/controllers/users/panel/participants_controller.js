import { Controller } from "stimulus"
import StimulusReflex from "stimulus_reflex"
import PanelHelper from "./helpers/panel_helper"

export default class extends Controller {

  connect() {
    StimulusReflex.register(this)
    this.panelHelper = new PanelHelper()
  }

  assignCase(event){
    let element = event.currentTarget
    const zoomUserId = this.panelHelper.getZoomUserId(element)
    if (this.panelHelper.isParticipantActive(element))
      this.panelHelper.zoomSDKHelper().putInWaitingRoom(zoomUserId)
    let caseNumbers = []
    for (let i = 0; i < event.target.parentNode.getElementsByTagName("input").length; i++) {
      caseNumbers.push(event.target.parentNode.getElementsByTagName("input")[i].value)
    }
    this.stimulate("PanelReflex#assign_to_case", event.target, caseNumbers)
  }

  removeUngroupedParticipant(event){
    if (confirm("Are you sure you want to remove this participant from the Zoom meeting?")) {
      let element = event.currentTarget
      const zoomUserId = this.panelHelper.getZoomUserId(element)
      this.panelHelper.zoomSDKHelper().removeParticipant(zoomUserId)
      this.stimulate("PanelReflex#remove_ungrouped_from_meeting", element)
    }
  }

  removeUngroupedParticipantFromPanel(event){
    if (confirm("Are you sure you want to remove this participant from the control panel? " +
                "Participant will remain in the Zoom meeting.")) {
      let element = event.currentTarget
      this.stimulate("PanelReflex#remove_ungrouped_from_control_panel", element)
    }
  }

  admitUngroupedParticipant(event){
    let element = event.currentTarget
    const zoomUserId = this.panelHelper.getZoomUserId(element)
    this.panelHelper.zoomSDKHelper().admitParticipant(zoomUserId)
    this.stimulate("PanelReflex#admit_ungrouped_participant", element)
  }

  putIntoWaitingRoomUngroupedParticipant(event){
    let element = event.currentTarget
    element.dataset.involvesZoomSDK = false
    const zoomUserId = this.panelHelper.getZoomUserId(element)
    this.panelHelper.zoomSDKHelper().putInWaitingRoom(zoomUserId)
    this.stimulate("PanelReflex#put_in_waiting_room_ungrouped", element)
  }
}
