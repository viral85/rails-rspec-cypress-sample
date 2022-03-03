import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "url" ]
  static values = {
    userUrl: String
  }

  copyUrl() {
    const userUrl = this.userUrlValue
    this.copyStringToClipboard(userUrl)
    this.urlTarget.innerHTML = "Copied!"
    this.addAnimationClasses()
    this.cleanUpAnimationClasses()
    setTimeout(() => {
      this.urlTarget.innerHTML = userUrl
      this.addAnimationClasses()
      this.cleanUpAnimationClasses()
    }, 3000)
  }

  copyStringToClipboard(str) {
    let el = document.createElement("textarea")
    el.value = str
    el.setAttribute("readonly", "")
    el.style = {position: "absolute", left: "-9999px"}
    document.body.appendChild(el)
    el.select()
    document.execCommand("copy")
    document.body.removeChild(el)
  }

  addAnimationClasses() {
    this.urlTarget.classList.add("animate__animated", "animate__fadeIn")
  }

  cleanUpAnimationClasses() {
    setTimeout(() => {
      this.urlTarget.classList.remove("animate__animated", "animate__fadeIn")
    }, 1000)
  }
}
