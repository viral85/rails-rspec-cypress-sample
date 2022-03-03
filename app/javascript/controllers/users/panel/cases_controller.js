import { Controller } from "stimulus"
import StimulusReflex from "stimulus_reflex"
import PanelHelper from "./helpers/panel_helper"

export default class extends Controller {
  panelHelper

  connect() {
    StimulusReflex.register(this)
    this.panelHelper = new PanelHelper()
  }

  startCase(event) {
    this.stimulate("PanelReflex#start_case", event.currentTarget)
    document.getElementById("search-input").value = ""
    this.admitAllParticipants(event.currentTarget.parentElement)
  }

  endCase(event) {
    this.stimulate("PanelReflex#end_case", event.currentTarget)
    const participants = event.currentTarget.parentElement
                              .getElementsByClassName("participant-container")
    Array.from(participants).forEach((element, index) => {
      setTimeout(() => {
        const zoomUserId = this.panelHelper.getZoomUserId(element)
        const hasOtherUpcomingMeeting = this.hasOtherUpcomingMeeting(element)
        if (hasOtherUpcomingMeeting == "true")
          this.panelHelper.zoomSDKHelper().putInWaitingRoom(zoomUserId)
        else
          this.panelHelper.zoomSDKHelper().removeParticipant(zoomUserId)
      }, index * 5600)
    })
  }

  beforeStartCase(element) {
    this.disableButton(element)
  }

  beforeEndCase(element) {
    this.disableButton(element)
  }

  startCaseWithSingleParticipant(event){
    let element = event.currentTarget
    const zoomUserId = this.panelHelper.getZoomUserId(element)
    this.panelHelper.zoomSDKHelper().admitParticipant(zoomUserId)
    this.stimulate("PanelReflex#start_case_with_single_participant", element)
    document.getElementById("search-input").value = ""
  }

  admitParticipant(event){
    let element = event.currentTarget
    const zoomUserId = this.panelHelper.getZoomUserId(element)
    this.panelHelper.zoomSDKHelper().admitParticipant(zoomUserId)
    this.stimulate("PanelReflex#admit_participant", element)
  }

  putInWaitingRoom(event){
    let element = event.currentTarget
    const zoomUserId = this.panelHelper.getZoomUserId(element)
    this.panelHelper.zoomSDKHelper().putInWaitingRoom(zoomUserId)
    this.stimulate("PanelReflex#put_in_waiting_room", element)
  }

  admitAll(event) {
    this.stimulate("PanelReflex#admit_all", event.currentTarget)
    const caseNumber = event.currentTarget.dataset.caseNumber
    const listElement = document.getElementById("participants-list-" + caseNumber)
    this.admitAllParticipants(listElement)
  }

  admitAllParticipants(target){
    const participants = target.getElementsByClassName("participant-container")
    Array.from(participants).forEach((element, index) => {
      setTimeout(() => {
        const zoomUserId = this.panelHelper.getZoomUserId(element)
        this.panelHelper.zoomSDKHelper().admitParticipant(zoomUserId)
      }, index * 1600)
    })
  }

  putAllInWaitingRoom(event) {
    this.stimulate("PanelReflex#put_all_in_waiting_room", event.currentTarget)
    const caseNumber = event.currentTarget.dataset.caseNumber
    const listElement = document.getElementById("participants-list-" + caseNumber)
    const participants = listElement.getElementsByClassName("participant-container")
    Array.from(participants).forEach((element, index) => {
      setTimeout(() => {
        const zoomUserId = this.panelHelper.getZoomUserId(element)
        this.panelHelper.zoomSDKHelper().putInWaitingRoom(zoomUserId)
      }, index * 1600)
    })
  }

  unassignFromCase(event){
    let element = event.currentTarget
    const zoomUserId = this.panelHelper.getZoomUserId(element)
    if (this.panelHelper.isParticipantActive(element))
      this.panelHelper.zoomSDKHelper().putInWaitingRoom(zoomUserId)
    this.stimulate("PanelReflex#unassign_from_case", element)
  }

  removeParticipant(event){
    if (confirm("Are you sure you want to remove this participant from the zoom meeting?")) {
      let element = event.currentTarget
      const zoomUserId = this.panelHelper.getZoomUserId(element)
      this.panelHelper.zoomSDKHelper().removeParticipant(zoomUserId)
      this.stimulate("PanelReflex#remove_from_meeting", element)
    }
  }

  removeParticipantFromPanel(event){
    if (confirm("Are you sure you want to remove this participant from the control panel? " +
                "Participant will remain in the Zoom meeting.")) {
      let element = event.currentTarget
      this.stimulate("PanelReflex#remove_from_control_panel", element)
    }
  }

  hasOtherUpcomingMeeting(element) {
    return element.closest(".participant-container").dataset.hasOtherUpcomingMeeting
  }



  disableButton(element){
    const id = element.id
    element.disable = true
    element.classList.add("hidden")
    document.getElementById("disabled-" + id).classList.remove("hidden")
  }
}
