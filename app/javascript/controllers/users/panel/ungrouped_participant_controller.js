import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["addItem", "template", "participantContainer", "assignButton"]
  index = 0

  connect() {
    this.updateIndexes()
  }

  validateCourtCaseField(event) {
    const parentId = event.target.dataset.parentId
    if(event.target.value != "" && !/\s/.test(event.target.value)){
      this.hideError(parentId)
      this.enableAssignButton()
    } else {
      this.showError(parentId)
      this.disableAssignButton()
    }
  }

  formCanBeSubmitted(){
    return this.noErrorsPresent() && this.nonEmptyCaseNumbers()
  }

  nonEmptyCaseNumbers(){
    for(const input of this.participantContainerTarget.querySelectorAll("input.case-number-input")){
      if(input.value == ""){
        return false
      }
    }
    return true
  }

  noErrorsPresent(){
    return this.participantContainerTarget
               .querySelectorAll(".invalid-notice:not(.hidden)").length == 0
  }

  participantToken(){
    return this.participantContainerTarget.dataset.participantToken
  }

  updateIndexes(){
    let elements = this.participantContainerTarget.querySelectorAll(".nested-fields")
    for (let i = 0; i < elements.length; i++) {
      let id = "case-index-" + this.participantToken() + "-" + i
      elements[i].id = id
      elements[i].querySelector(".case-number-input").dataset.parentId = id
    }
  }

  addAssociation(event){
    event.preventDefault()
    const participantToken = event.target.dataset.participant
    let content = this.templateTarget.innerHTML.replace(/TEMPLATE_RECORD/g, new Date().valueOf())
    content = content.replace(/ATTENDANCE_TOKEN/g, participantToken)
    event.target.insertAdjacentHTML("beforebegin", content)
    this.updateIndexes()

    this.disableAssignButton()
  }

  removeAssociation(event) {
    event.preventDefault()
    let item = event.target.closest(".nested-fields")
    item.remove()
    this.updateIndexes()
    this.enableAssignButton()
  }

  showError(parentId){
    this.participantContainerTarget
        .querySelector("#" + parentId + " .input-error").classList.remove("hidden")
  }

  hideError(parentId){
    this.participantContainerTarget
        .querySelectorAll("#" + parentId + " .input-error").forEach((el) => {
          el.classList.add("hidden")
        })
  }

  disableAssignButton(){
    this.assignButtonTarget.disabled = true
    this.assignButtonTarget.classList.add("opacity-50")
    this.assignButtonTarget.dataset.valid = "false"
  }

  enableAssignButton(){
    if(this.formCanBeSubmitted()){
      this.assignButtonTarget.disabled = false
      this.assignButtonTarget.classList.remove("opacity-50")
      this.assignButtonTarget.dataset.valid = "true"
    }
  }
}
