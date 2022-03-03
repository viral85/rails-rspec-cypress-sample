describe("Manage cases", function(){
  beforeEach(function(){
    cy.app("clean")
      .then(() => cy.appFactories([["create", "user"]]))
      .then(() => cy.appFactories([["create", "zoom_meeting"]]))
      .then(() => cy.appFactories([["create", "identity"]]))
      .then(() => cy.app("enable_webmock"))
      .then(() => cy.appStubs("get_meeting"))
      .then(() => cy.app("login"))
      .then(() => cy.appScenario("generate_case_with_participants"))
      .then(() => cy.appScenario("generate_case_with_participants"))
      .then(() => cy.visit("/panel/"))
      .then(() => cy.waitForStimlulusReflexToBeReady())
  })

  it("starts case & end case", () => {
    cy.getBySel("upcoming-cases")
      .findBySel("case-container")
      .should("have.length", 2)

    cy.startUpcomingCase({index: 0})

    cy.checkActiveCaseStatus({waiting_room_count: 0, meeting_room_count: 3})

    cy.getActiveCase()
      .should("contain", "00:00:0")
      .checkParticipantsStatus({waiting_room_count: 0, loading_count: 3, meeting_room_count: 0})

    cy.getBySel("upcoming-cases")
      .findBySel("case-container")
      .should("have.length", 1)

    cy.getBySel("upcoming-cases")
      .findBySel("start-case-btn")
      .should("be.disabled")

    cy.wait(4000) // zoom sdk request waiting process

    cy.endActiveCase()

    cy.getBySel("control-panel")
      .findBySel("case-container")
      .should("have.length", 1)

    cy.getBySel("active-case")
      .findBySel("case-container")
      .should("not.exist")

    cy.wait(10000) // zoom sdk request waiting process

    cy.getBySel("upcoming-cases")
      .findBySel("start-case-btn")
      .should("not.be.disabled")
      .should("be.visible")
  })

  context("perform action on participants", () => {
    it("starts case by adding participant", () => {
      cy.getUpcomingCase(0)
        .findBySel("toggle-participants-list-btn")
        .should("be.visible")
        .click()
        .waitForStimlulusReflexToBeReady()

      cy.getUpcomingCase(0)
        .findBySel("participants-list-container")
        .findBySel("participant")
        .should("have.length", 3)
        .eq(0)
        .findBySel("participant-dropdown")
        .click()

      cy.getUpcomingCase(0)
        .findBySel("participant")
        .eq(0)
        .findBySel("add-single-participant-btn")
        .click()
        .waitForStimlulusReflexToBeReady()

      cy.checkActiveCaseStatus({waiting_room_count: 2, meeting_room_count: 1})

      cy.getActiveCase()
        .checkParticipantsStatus({waiting_room_count: 2, loading_count: 1, meeting_room_count: 0})

      cy.getActiveCase()
        .findBySel("participants-list-container")
        .findBySel("participant")
        .eq(0)
        .should("not.contain", "0 min")

      cy.getActiveCase()
        .findBySel("participants-list-container")
        .findBySel("participant")
        .eq(1)
        .should("contain", "0 min")

      cy.getBySel("upcoming-cases")
        .findBySel("case-container")
        .should("have.length", 1)
    })

    context("when participants are already in the meeting room", () => {
      beforeEach(() => {
        cy.startUpcomingCase({index: 0})
          .appScenario("place_participants_into_meeting_room")
          .reload()
          .waitForStimlulusReflexToBeReady()

        cy.getActiveCase()
          .checkParticipantsStatus({
            waiting_room_count: 0, loading_count: 0, meeting_room_count: 3
          })

        cy.getActiveCase()
          .findParticipant(0)
          .findBySel("participant-dropdown")
          .click()
      })

      it("places into the waiting room", () => {
        cy.getActiveCase()
          .findParticipant(0)
          .findBySel("place-into-waiting-room")
          .click()
          .waitForStimlulusReflexToBeReady()

        cy.checkActiveCaseStatus({waiting_room_count: 1, meeting_room_count: 2})

        cy.getActiveCase()
          .checkParticipantsStatus({
            waiting_room_count: 1, loading_count: 0, meeting_room_count: 2
          })
      })

      it("removes from the meeting room", () => {
        cy.getActiveCase()
          .findParticipant(0)
          .findBySel("remove-participant")
          .click()
          .waitForStimlulusReflexToBeReady()

        cy.checkActiveCaseStatus({waiting_room_count: 0, meeting_room_count: 2})

        cy.getActiveCase()
          .checkParticipantsStatus({
            waiting_room_count: 0, loading_count: 0, meeting_room_count: 2
          })
      })
    })
  })
})
