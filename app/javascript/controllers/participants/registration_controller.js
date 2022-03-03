import { Controller } from "stimulus"
import StimulusReflex from "stimulus_reflex"
import debounced from "debounced"

export default class extends Controller {
  static targets = ["addItem", "template"]
  index = 0
  env = document.querySelector("meta[name='env']").content

  connect(){
    StimulusReflex.register(this)
    this.updateIndexes()
    this.hideRemoveButton()
    this.disableSubmitButton()
    debounced.initialize({ input: { wait: 500 } })
  }

  toggleCase(event){
    let id = (event.target.id == "") ? event.target.parentElement.parentElement.id : event.target.id
    let element = document.getElementById(id)
    let selected_symbol = element.querySelector(".selected_case")
    if(selected_symbol.classList.contains("hidden")){
      selected_symbol.classList.remove("hidden")
      element.insertAdjacentHTML(
        "beforeend",
        "<input id='"+ id +"-input' type='hidden' name='participant[court_cases_attributes]["+ id +
        "][case_number]' value='"+ id.replace("case-", "") + "'>"
      )
      this.enableSubmitButton()
    } else {
      selected_symbol.classList.add("hidden")
      document.getElementById(id+"-input").remove()
      this.disableSubmitButton()
    }
  }

  validateCourtCase(event) {
    const caseNumber = event.target.value
    const parentId = event.target.parentElement.id
    if(/\s/.test(event.target.value)){
      this.displayCaseNumberError(parentId)
      this.disableSubmitButton()
    } else{
      this.stimulate("Registration#validate_case", caseNumber, parentId)
    }
  }

  validateField(event){
    let id = event.target.id
    let user_input = event.target.value
    if(user_input == "" || /^\s*$/.test(user_input) || user_input[0] == " "){
      user_input[0] == " " ? this.displayWhitespaceError(id) : this.displayInvalidFieldError(id)
      this.disableSubmitButton()
    } else{
      this.hideValidationError(id)
      this.enableSubmitButton()
    }
  }

  showLoadSpinner(event){
    const parentId = event.target.parentElement.id
    let element = document.getElementById(parentId)
    element.querySelector(".success-validation").classList.add("hidden")
    element.querySelector(".load-spinner").classList.remove("hidden")
    this.disableSubmitButton()
  }

  addAssociation(event) {
    event.preventDefault()
    const content = this.templateTarget.innerHTML.replace(/TEMPLATE_RECORD/g, new Date().valueOf())
    this.addItemTarget.insertAdjacentHTML("beforebegin", content)
    if(document.getElementsByClassName("nested-fields").length > 1){ this.index++ }
    document.getElementsByClassName("nested-fields")[this.index].id = "case-index-" + this.index
    this.disableSubmitButton()
  }

  removeAssociation(event) {
    event.preventDefault()
    let item = event.target.closest(".nested-fields")
    item.querySelector("input[name*='_destroy']").value = 1
    item.remove()
    if(document.getElementsByClassName("nested-fields").length > 0){ this.index-- }
    this.updateIndexes()
    this.enableSubmitButton()
  }

  updateIndexes(){
    let element = document.getElementsByClassName("nested-fields")
    for (let i = 0; i < element.length; i++) {
      element[i].id = "case-index-" + i
    }
  }

  hideRemoveButton(){
    if(document.getElementsByClassName("nested-fields").length > 0){
      let element = document.getElementsByClassName("nested-fields")[0]
      element.querySelector(".remove-button").remove()
    }
  }

  disableSubmitButton(){
    if(this.formCannotBeSubmitted()){
      document.getElementById("submit-btn").disabled = true
      document.getElementById("submit-btn").classList.add("opacity-50")
    }
  }

  enableSubmitButton(){
    if(this.formCanBeSubmitted()){
      document.getElementById("submit-btn").disabled = false
      document.getElementById("submit-btn").classList.remove("opacity-50")
    } else{
      this.disableSubmitButton()
    }
  }

  displayCaseNumberError(id){
    let element = document.getElementById(id)
    element.querySelector(".success-validation").classList.add("hidden")
    element.querySelector(".load-spinner").classList.add("hidden")
    element.querySelector(".case-input").classList.remove("border-z-blue")
    element.querySelector(".case-input").classList.add("border-z-red")
    element.querySelector(".invalid-notice").classList.remove("hidden")
  }

  displayInvalidFieldError(id){
    document.getElementById(id + "-error").classList.remove("hidden")
    document.getElementById(id).classList.add("border-z-red")
  }

  displayWhitespaceError(id){
    document.getElementById(id + "-error2").classList.remove("hidden")
    document.getElementById(id).classList.add("border-z-red")
  }

  hideValidationError(id){
    if(id != "role"){
      document.getElementById(id + "-error2").classList.add("hidden")
    }
    document.getElementById(id + "-error").classList.add("hidden")
    document.getElementById(id).classList.remove("border-z-red")
  }

  submitForm(){
    if(this.formCanBeSubmitted()){
      this.disableSubmitButton()
    }
  }

  formCanBeSubmitted(){
    return this.noErrorsPresent() && this.validPersonalInfoInputs() &&
      this.nonEmptyCaseNumbers() &&
      (this.aCaseIsEntered() || this.aCaseIsSelected() ||
        document.getElementById("first-name") != null)
  }

  formCannotBeSubmitted(){
    return !this.noErrorsPresent() || !this.validPersonalInfoInputs() ||
      !this.nonEmptyCaseNumbers() || (this.aCaseIsNotSelected() && this.aCaseIsNotEntered())
    || this.loadingIconIsVisible()
  }

  validPersonalInfoInputs(){
    if(document.getElementById("first-name") != null){
      return document.getElementById("first-name").value != ""
      && document.getElementById("last-name").value != ""
      && document.getElementById("role").value != ""
    }
    return true
  }

  loadingIconIsVisible(){
    return document.querySelectorAll(".load-spinner:not(.hidden)").length > 0
  }

  aCaseIsNotEntered(){
    return document.getElementsByClassName("nested-fields").length == 0
  }

  aCaseIsEntered(){
    return document.getElementsByClassName("nested-fields").length > 0
  }

  aCaseIsNotSelected(){
    return document.querySelectorAll(".selected_case:not(.hidden)").length == 0
  }

  aCaseIsSelected(){
    return document.querySelectorAll(".selected_case:not(.hidden)").length > 0
  }

  noErrorsPresent(){
    return document.querySelectorAll(".invalid-notice:not(.hidden)").length == 0
  }

  nonEmptyCaseNumbers(){
    for (const input of document.querySelectorAll("input.form-input")) {
      if(input.value == ""){
        return false
      }
    }
    return true
  }
}
