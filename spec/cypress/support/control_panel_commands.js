Cypress.Commands.add("getCaseComponent", { prevSubject: true }, (subject, index) => {
  return cy.wrap(subject)
           .find("[data-cy=case-container]")
           .eq(index)
})

Cypress.Commands.add("getActiveCase", () => {
  return cy.getBySel("active-case")
           .findBySel("case-container")
           .should("have.length", 1)
           .should("be.visible")
})

Cypress.Commands.add("getUpcomingCase", (index=1) => {
  return cy.getBySel("upcoming-cases")
           .findBySel("case-container")
           .eq(index)
           .should("be.visible")
})


Cypress.Commands.add("endActiveCase", () => {
  return cy.getActiveCase()
           .findBySel("end-case-btn")
           .should("be.visible")
           .click()
           .waitForStimlulusReflexToBeReady()
})

Cypress.Commands.add("startUpcomingCase", ({index=0}) => {
  return cy.getBySel("upcoming-cases")
           .findBySel("case-container")
           .eq(index)
           .findBySel("start-case-btn")
           .should("be.visible")
           .should("not.be.disabled")
           .click()
           .waitForStimlulusReflexToBeReady()
})

Cypress.Commands.add("findParticipant", { prevSubject: true }, (subject, index=0) => {
  return cy.wrap(subject)
           .findBySel("participants-list-container")
           .findBySel("participant")
           .eq(index)
})

Cypress.Commands.add("checkActiveCaseStatus", ({waiting_room_count, meeting_room_count}) => {
  if (waiting_room_count == 0)
    cy.getActiveCase()
      .findBySel("in-waiting-room-counter")
      .should("not.exist")
  else
    cy.getActiveCase()
      .findBySel("in-waiting-room-counter")
      .should("contain", waiting_room_count)

  if (meeting_room_count == 0)
    cy.getActiveCase()
      .findBySel("in-meeting-room-counter")
      .should("not.exist")
  else
    cy.getActiveCase()
      .findBySel("in-meeting-room-counter")
      .should("contain", meeting_room_count)
})

Cypress.Commands.add("checkParticipantsStatus", { prevSubject: true },
                     (subject, {waiting_room_count, loading_count, meeting_room_count}) => {
  cy.wrap(subject)
    .findBySel("blue-dot-indicator")
    .should("have.length", waiting_room_count)

  cy.wrap(subject)
    .findBySel("green-dot-indicator")
    .should("have.length", meeting_room_count)

  cy.wrap(subject)
    .findBySel("loading-spinner")
    .should("have.length", loading_count)
})
