import { Controller } from "stimulus"
import StimulusReflex from "stimulus_reflex"
export default class extends Controller {
  connect () {
    StimulusReflex.register(this)
  }

  beforeReflex (element, reflex, noop, reflexId) {}

  reflexSuccess (element, reflex, noop, reflexId) {}

  reflexError (element, reflex, error, reflexId) {}

  afterReflex (element, reflex, noop, reflexId) {}
}
