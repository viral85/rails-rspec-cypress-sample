import { Controller } from "stimulus"

export default class extends Controller {
  activeTabClassesList = ["-mb-px", "border-l", "border-t", "border-r", "rounded-t", "bg-white"]
  inactiveTabClassesList = ["text-gray-500", "bg-z-gray-lightest"]

  static targets = ["casesPanel", "participantsPanel", "casesTab", "participantsTab"]
  static values = { firstTab: String }

  connect() {
    this.initializeTabs()
  }

  initializeTabs() {
    if (this.firstTabValue == "cases")
      this.switchToCasesTab()
    else if (this.firstTabValue == "participants")
      this.switchToParticipantsTab()
    this.casesTabTarget.addEventListener("click", () => {
      this.switchToCasesTab()
    })

    this.participantsTabTarget.addEventListener("click", () => {
      this.switchToParticipantsTab()
    })
  }

  switchToCasesTab() {
    this.casesPanelTarget.classList.remove("hidden")
    this.participantsPanelTarget.classList.add("hidden")

    this.casesTabTarget.classList.add(...this.activeTabClassesList)
    this.casesTabTarget.classList.remove(...this.inactiveTabClassesList)

    this.participantsTabTarget.classList.add(...this.inactiveTabClassesList)
    this.participantsTabTarget.classList.remove(...this.activeTabClassesList)
  }

  switchToParticipantsTab() {
    this.casesPanelTarget.classList.add("hidden")
    this.participantsPanelTarget.classList.remove("hidden")

    this.participantsTabTarget.classList.add(...this.activeTabClassesList)
    this.participantsTabTarget.classList.remove(...this.inactiveTabClassesList)

    this.casesTabTarget.classList.add(...this.inactiveTabClassesList)
    this.casesTabTarget.classList.remove(...this.activeTabClassesList)
  }

}
