import { Controller } from "stimulus"
import StimulusReflex from "stimulus_reflex"

export default class extends Controller {
  static targets = ["shareLinkInput"]

  connect() {
    StimulusReflex.register(this)
  }

  toggleShareLinkOption(){
    this.stimulate("ShareLinkReflex#toggle_sharing", event.target.value)
  }


}
