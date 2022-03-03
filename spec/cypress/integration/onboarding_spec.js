describe("Onboarding page", function(){
  beforeEach(function(){
    cy.app("clean")
      .then(() => cy.appFactories([["create", "user"]]))
      .then(() => cy.appFactories([["create", "zoom_meeting"]]))
      .then(() => cy.appFactories([["create", "identity"]]))
      .then(() => cy.app("enable_webmock"))
      .then(() => cy.appStubs("get_meeting"))
      .then(() => cy.app("login"))
  })


  it("shows getting-started in menu with badge on how many steps left", () => {
    cy.visit("/")

    cy.getBySel("onboarding-counter")
      .should("contain", "3")
    cy.getBySel("onboarding-menu-item")
      .click()

    cy.url().should("include", "/getting-started")
  })

  it("allow user to complete the onboarding", () => {
    cy.visit("/getting-started")

    cy.getBySel("complete-step-1")
      .click()
      .waitForStimlulusReflexReadyEvent()

    cy.getBySel("complete-step-2")
      .click()
      .waitForStimlulusReflexReadyEvent()

    cy.getBySel("complete-step-3")
      .click()
      .waitForStimlulusReflexReadyEvent()

    cy.url().should("not.include", "/getting-started")

    cy.getBySel("notification")
      .should("contain", "Great job! You are ready to start using xyz.io")

    cy.getBySel("onboarding-menu-item")
      .should("not.exist")
  })
})
