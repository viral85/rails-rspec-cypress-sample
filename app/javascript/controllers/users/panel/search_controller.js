import { Controller } from "stimulus"
import StimulusReflex from "stimulus_reflex"
import debounced from "debounced"

export default class extends Controller {
  connect() {
    debounced.initialize({ input: { wait: 200 } }) // wait 200 ms before firing inout event
    StimulusReflex.register(this)
  }

  filterUpcomingCourtCases(event) {
    const searchQuery = event.target.value
    this.stimulate("Panel#filter_upcoming_cases", searchQuery)
  }

  SetGrayInSearch(){
    document.getElementById("search-background").classList.remove("bg-white")
    document.getElementById("search-background").classList.add("bg-z-gray-lightest")
    document.getElementById("search-input").classList.remove("bg-z-gray-lightest")
    document.getElementById("search-input").classList.add("bg-white")
  }

  SetWhiteInSearch(){
    document.getElementById("search-background").classList.remove("bg-z-gray-lightest")
    document.getElementById("search-background").classList.add("bg-white")
    document.getElementById("search-input").classList.remove("bg-white")
    document.getElementById("search-input").classList.add("bg-z-gray-lightest")
  }
}

