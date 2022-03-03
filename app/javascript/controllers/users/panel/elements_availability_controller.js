import { Controller } from "stimulus"
import StimulusReflex from "stimulus_reflex"

export default class extends Controller {
  sdkRequestLoader = document.getElementById("loadingSdkRequestStatus")
  reconnectLoader = document.getElementById("reconnectingWebsocketsStatus")
  cableConnected = true

  connect(){
    StimulusReflex.register(this)
    this.bindReflexSuccessListener()
    this.bindWSConnectionLostListener()
    this.bindWSConnectionOpenedListener()
    this.updateAvailability()
    this.setAvailabilityUpdater()
  }

  setAvailabilityUpdater() {
    setInterval(() => { this.updateAvailability()}, 500)
  }

  nextZoomSdkRequestAvailableAt() {
    const nextZoomSdkRequestAvailableAtValue =
      document.getElementById("nextSdkRequestAvailabilityValueHolder")
              .dataset.nextZoomSdkRequestAvailableAtValue
    return Date.parse(nextZoomSdkRequestAvailableAtValue)
  }

  sdkRequestsAvailable() {
    if (!this.nextZoomSdkRequestAvailableAt())
      return true
    return this.nextZoomSdkRequestAvailableAt() < Date.now()
  }

  bindReflexSuccessListener() {
    document.addEventListener("stimulus-reflex:finalize", _event => {
      this.updateAvailability()
    })
  }

  updateAvailability() {
    if (this.cableConnected == false) return

    if (!this.sdkRequestsAvailable()) {
      this.freezeSDKElements()
    }
    else {
      this.unfreezeSDKElements()
    }
  }

  bindWSConnectionLostListener() {
    document.addEventListener("websocket-connection-lost", (e) => {
      this.setReconnectingState()
    })

    document.addEventListener("stimulus-reflex:disconnected", (e) => {
      this.setReconnectingState()
    })
  }

  bindWSConnectionOpenedListener() {
    document.addEventListener("stimulus-reflex:connected", e => {
      setTimeout(() => {
        if (!this.cableConnected) this.setConnectedState()
      }, 500)
    })
  }

  setReconnectingState() {
    this.reconnectLoader.classList.remove("hidden")
    this.cableConnected = false
    this.freezeAll()
  }

  setConnectedState() {
    this.stimulate("PanelReflex#full_update_panel", this.activeTab()).then(() => {
      this.reconnectLoader.classList.add("hidden")
      this.cableConnected = true
      this.unfreezeAll()
    })
  }

  activeTab() {
    if (document.getElementById("cases").classList.contains("hidden"))
      return "participant"
    else
      return "cases"
  }

  freezeSDKElements() {
    this.sdkRequestLoader.classList.remove("hidden")
    this.freezeElements(this.elementsInvolvingSDK())
  }

  unfreezeSDKElements() {
    this.sdkRequestLoader.classList.add("hidden")
    this.unfreezeElements(this.elementsInvolvingSDK())
  }

  freezeAll() {
    this.sdkRequestLoader.classList.add("hidden")
    this.freezeElements(this.allClickableElements())
  }

  unfreezeAll() {
    this.unfreezeElements(this.allClickableElements())
  }

  freezeElements(elements) {
    elements.forEach((el) => { this.disableElement(el) })
  }

  unfreezeElements(elements) {
    elements.forEach((el) => {
      if (this.elementIsAvailable(el))
        this.enableElement(el)
    })
  }

  elementsInvolvingSDK() {
    return document.querySelectorAll("[data-involves-zoom-sdk='true']")
  }

  allClickableElements() {
    return document.querySelectorAll("a, button")
  }

  elementIsAvailable(el) {
    const activeCaseIsPresent = document.getElementsByClassName("active-case").length > 0
    return (el.dataset.startCaseBtn === "true" && !activeCaseIsPresent) ||
            el.dataset.startCaseBtn !== "true"
  }

  disableElement(el) {
    el.classList.add("opacity-50", "deactivated-link")
    el.disabled = true
  }

  enableElement(el) {
    if (el.dataset.valid !== "false") {
      el.classList.remove("opacity-50", "deactivated-link")
      el.disabled = false
    }
  }
}

