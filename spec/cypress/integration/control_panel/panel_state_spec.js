describe("Panel State", function(){
  beforeEach(function(){
    cy.app("clean")
      .then(() => cy.appFactories([["create", "user"]]))
      .then(() => cy.appFactories([["create", "zoom_meeting"]]))
      .then(() => cy.appFactories([["create", "identity"]]))
      .then(() => cy.app("enable_webmock"))
      .then(() => cy.appStubs("get_meeting"))
      .then(() => cy.app("login"))
  })

  context("when there is no cases with available participants", () => {
    it("shows message about no participants", () => {
      cy.visit("/panel/")
        .then(() => cy.waitForStimlulusReflexToBeReady())

      cy.getBySel("no-cases-message-container")
        .should("contain", "There are currently no cases with participants in the waiting room.")

      cy.getBySel("cases-content")
        .should("not.be.visible")

      cy.getBySel("participants-tab")
        .click()

      cy.getBySel("no-participants-message-container")
        .should("contain", "There are currently no ungrouped participants in the waiting room.")

      cy.getBySel("ungrouped-participants-content")
        .should("not.be.visible")
    })

    it("shows panel with case in real-time control when case become available", () => {
      cy.appScenario("generate_case_with_participants")
        .then(() => cy.appScenario("generate_participant_without_case"))
        .then(() => cy.visit("/panel/"))
        .then(() => cy.waitForStimlulusReflexToBeReady())

      cy.getBySel("cases-content")
        .should("be.visible")

      cy.getBySel("upcoming-cases")
        .findBySel("case-container")
        .should("have.length", 1)

      cy.getBySel("participants-tab")
        .click()

      cy.getBySel("ungrouped-participants-content")
        .should("be.visible")

      cy.getBySel("ungrouped-participants-content")
        .findBySel("ungrouped-participant")
        .should("have.length", 1)
    })
  })

  describe("inactive case state", () => {
    it("display inactive case state correctly", () => {
      const numberOfParticipants = 2
      cy.appScenario("generate_case_with_participants",
                      { number_of_participants: numberOfParticipants }
                    )
        .then(() => cy.visit("/panel/"))
        .then(() => cy.waitForStimlulusReflexToBeReady())

      cy.getBySel("case-container")
        .findBySel("start-case-btn")
        .should("not.be.disabled")

      cy.getBySel("case-container")
        .findBySel("in-waiting-room-counter")
        .should("contain", numberOfParticipants)

      cy.getBySel("case-container")
        .findBySel("in-meeting-room-counter")
        .should("not.exist")

      cy.getBySel("participants-list-container")
        .should("not.be.visible")

      cy.getBySel("toggle-participants-list-btn")
        .should("be.visible")
        .click()
        .waitForStimlulusReflexToBeReady()

      cy.getBySel("participants-list-container")
        .findBySel("participant")
        .should("have.length", numberOfParticipants)

      cy.getBySel("participants-list-container")
        .findBySel("participant")
        .eq(0)
        .should("contain", "0 min")

      cy.getBySel("participants-list-container")
        .findBySel("participant")
        .eq(0)
        .findBySel("participant-dropdown")
        .click()

      cy.getBySel("participants-list-container")
        .findBySel("participant")
        .eq(0)
        .findBySel("add-participant-btn")
        .should("be.visible")
    })
  })

  describe("persists data when refreshing page", () => {
    beforeEach(() => {
      cy.appScenario("generate_case_with_participants")
        .then(() => cy.appScenario("generate_case_with_participants"))
        .then(() => cy.visit("/panel/"))
        .then(() => cy.waitForStimlulusReflexToBeReady())
    })

    it("persits timers", () => {
      cy.get("[data-cy=upcoming-cases]")
        .find("[data-cy=case-container]")
        .should("be.have.length", 2)

      cy.getBySel("toggle-participants-list-btn")
        .should("be.visible")
        .eq(0)
        .click()
        .waitForStimlulusReflexToBeReady()

      cy.getUpcomingCase(0)
        .findParticipant(0)
        .findBySel("participant-dropdown")
        .click()

      cy.getUpcomingCase(0)
        .findParticipant(0)
        .findBySel("add-single-participant-btn")
        .click()
        .appScenario("update_timers")
        .waitForStimlulusReflexToBeReady()

      cy.reload()

      cy.get("[data-cy=active-case]")
        .should("be.visible")

      cy.get("[data-cy=active-case]")
        .find("[data-cy=case-container]")
        .should("be.have.length", 1)
        .should("contain", "00:05:0")

      cy.get("[data-cy=active-case]")
        .findBySel("participants-list-container")
        .should("be.visible")
        .find("[data-cy=participant]")
        .eq(1)
        .should("contain", "5 min")

    })
  })
})
