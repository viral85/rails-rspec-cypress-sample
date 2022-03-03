import { Controller } from "stimulus"
import autocomplete from "autocomplete.js"

export default class extends Controller {
  static targets = ["field", "container"]

  search(query, callback) {
    const existingCases = document.getElementById("existingCases")
                                  .dataset.courtCasesString.split(" ")
                                  .map(caseNumber => { return { name: caseNumber } })
    const filteredCases = existingCases.filter((caseNumber) => {
      return caseNumber.name.toLowerCase().includes(query.toLowerCase())
    })
    callback(filteredCases)
  }

  connect(){
    this.ac = autocomplete(this.fieldTarget, { hint: false }, [
      {
        source: this.search,
        debounce: 200,
        templates: {
          suggestion: function (suggestion) {
            return suggestion.name
          },
        }
      },
    ]).on("autocomplete:selected", (event, suggestion, dataset, context) => {
      this.ac.autocomplete.setVal(suggestion.name)
    })
  }
}
