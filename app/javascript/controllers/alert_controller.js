import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "output" ]

  initialize(){
    setTimeout(() => {
      this.alertFadeOut()
    }, 10000)
  }

  alertFadeOut(){
    const alert = document.querySelector("#alert-div")
    if (alert) {
      alert.classList.add("animate__animated", "animate__fadeOut")
      setTimeout(() => { alert.classList.add("hidden") }, 1000)
    }
  }
}
