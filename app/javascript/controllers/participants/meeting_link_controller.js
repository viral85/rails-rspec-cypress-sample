import { Controller } from "stimulus"
import StimulusReflex from "stimulus_reflex"
import debounced from "debounced"

export default class extends Controller {
  connect(){
    StimulusReflex.register(this)

    debounced.initialize({ input: { wait: 500 } })
  }
}
