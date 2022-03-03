import { Controller } from "stimulus"
import StimulusReflex from "stimulus_reflex"
import PanelHelper from "./helpers/panel_helper"

export default class extends Controller {
  static targets = ["editParticipantForm", "firstNameInput", "lastNameInput", "roleInput",
                    "assignCaseForm", "firstNameError", "lastNameError"]
  connect() {
    StimulusReflex.register(this)
    this.panelHelper = new PanelHelper()
  }

  saveParticipant() {
    const firstName = this.firstNameInputTarget.value
    const lastName = this.lastNameInputTarget.value
    const role = this.roleInputTarget.value

    const oldUserName = this.zoomUsername()
    const newUsername = `${firstName} ${lastName} - ${role}`
    const zoomUserId = this.zoomUserId()

    this.panelHelper.zoomSDKHelper().renameParticipant({
      zoomUserId: zoomUserId,
      oldName: oldUserName,
      newName: newUsername
    }, {
      participantToken: this.participantToken(),
      firstName: firstName,
      lastName: lastName,
      role: role
    })
    this.hideEditParticipantForm()
  }

  hideEditParticipantForm() {
    this.editParticipantFormTarget.classList.add("hidden")
    this.assignCaseFormTarget.classList.remove("hidden")
  }

  showEditParticipantForm(){
    this.editParticipantFormTarget.classList.remove("hidden")
    this.assignCaseFormTarget.classList.add("hidden")
  }

  zoomUserId() {
    return parseInt(this.element.dataset.zoomUserId)
  }

  zoomUsername() {
    return this.element.dataset.zoomUsername
  }

  participantToken() {
    return this.element.dataset.participantToken
  }

  validateFirstName(event) {
    if (event.currentTarget.value == "")
      this.firstNameErrorTarget.classList.remove("hidden")
    else
      this.firstNameErrorTarget.classList.add("hidden")
  }

  validateLastName(event) {
    if (event.currentTarget.value == "")
      this.lastNameErrorTarget.classList.remove("hidden")
    else
      this.lastNameErrorTarget.classList.add("hidden")
  }
}
