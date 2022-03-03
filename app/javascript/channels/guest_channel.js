import consumer from "./consumer"
import { getConsumerType } from "./consumer"

const consumerType = getConsumerType()
if (consumerType == "Guest") {
  consumer.subscriptions.create("GuestChannel", {
    connected() {
      // Called when the subscription is ready for use on the server
    },

    disconnected() {
      // Called when the subscription has been terminated by the server
    },

    received(data) {
      if(data.status == true){
        setInputAsValid(data)
        enableSubmitButton()
        hideAlternativeSubmitButton()
      } else{
        setInputAsInvalid(data)
        disableSubmitButton()
        showAlternativeSubmitButton()
      }
      hideLoadSpinner(data.case_index)
    }
  })
}

function setInputAsValid(data){
  let element = document.getElementById(data.case_index)
  element.querySelector(".case-input").classList.remove('border-z-red')
  element.querySelector(".case-input").classList.add('border-z-blue')
  element.querySelector(".invalid-notice").classList.add('hidden')
  element.querySelector(".success-validation").classList.remove('hidden')
}

function setInputAsInvalid(data){
  let element = document.getElementById(data.case_index)
  element.querySelector(".case-input").classList.remove('border-z-blue')
  element.querySelector(".case-input").classList.add('border-z-red')
  element.querySelector(".success-validation").classList.add('hidden')
  element.querySelector(".invalid-notice").classList.remove('hidden')
}

function hideAlternativeSubmitButton(){
  if(document.getElementById("submit-btn2") != undefined){
    document.getElementById("submit-btn2").disabled = true
    document.getElementById("submit-btn2").classList.add('hidden')
  }
}

function showAlternativeSubmitButton(){
  if(document.getElementById("submit-btn2") != undefined){
    document.getElementById("submit-btn2").disabled = false
    document.getElementById("submit-btn2").classList.remove('hidden')
  }
}

function disableSubmitButton(){
  document.getElementById("submit-btn").disabled = true
  document.getElementById("submit-btn").classList.add('opacity-50')
}

function enableSubmitButton(){
  if(document.querySelectorAll(".invalid-notice:not(.hidden)").length == 0 &&
  validPersonalInfoInputs() && nonEmptyCaseNumbers()){
    document.getElementById("submit-btn").disabled = false
    document.getElementById("submit-btn").classList.remove('opacity-50')
  }
}

function hideLoadSpinner(case_index){
  let element = document.getElementById(case_index)
  element.querySelector(".load-spinner").classList.add('hidden')
}

function validPersonalInfoInputs(){
  if(document.getElementById("first-name") != null){
    return document.getElementById("first-name").value != ""
    && document.getElementById("last-name").value != ""
    && document.getElementById("role").value != ""
  }
  return true
}

function nonEmptyCaseNumbers(){
  for (const input of document.querySelectorAll("input.form-input")) {
    if(input.value == ""){
      return false
    }
  }
  return true
}
