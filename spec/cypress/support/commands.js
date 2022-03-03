import "cypress-wait-until"

Cypress.Commands.add("waitForStimlulusReflexToBeReady", () => {
  cy.document()
    .then($document => {
      return new Cypress.Promise(resolve => {
        setTimeout(() => { resolve() }, 500) // TEMP solution. Apperently more stable on CI than SR:ready event
      })
    })
})

Cypress.Commands.add("waitForStimlulusReflexReadyEvent", () => {
  cy.document()
    .then($document => {
      return new Cypress.Promise(resolve => { // Cypress will wait for this Promise to resolve
        const onQueryEnd = () => {
          $document.removeEventListener("stimulus-reflex:ready", onQueryEnd) // cleanup
          resolve() // resolve and allow Cypress to continue
        }
        $document.addEventListener("stimulus-reflex:ready", onQueryEnd)
      })
    })
})

Cypress.Commands.add("getBySel", (selector, ...args) => {
  return cy.get(`[data-cy=${selector}]`, ...args)
})

Cypress.Commands.add("findBySel", { prevSubject: true }, (subject, selector, ...args) => {
  return cy.wrap(subject).find(`[data-cy=${selector}]`, ...args)
})
