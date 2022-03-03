describe("Search cases", function(){
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
      .then(() => cy.appScenario("generate_case_with_participants"))
      .then(() => cy.appScenario("generate_case_with_participants"))
      .then(() => cy.visit("/panel/"))
      .then(() => cy.waitForStimlulusReflexToBeReady())
  })

  it("searches cases", () => {
    cy.getBySel("upcoming-cases")
      .findBySel("case-container")
      .should("have.length", 4)

    cy.getBySel("upcoming-cases")
      .findBySel("case-container")
      .eq(0)
      .findBySel("case-number")
      .invoke("text")
      .as("case1Number")

    // Search by common part that multiple cases include (all in this test cases)
    cy.getBySel("search-input")
      .type("B000")

    cy.getBySel("search-results")
      .findBySel("case-container")
      .should("have.length", 2)

    // Clean up search input
    cy.getBySel("search-input")
      .clear()

    cy.getBySel("search-results")
      .findBySel("case-container")
      .should("have.length", 0)

    // search by specific case number
    cy.get("@case1Number").should("contain", "Case B000")

    cy.get("@case1Number")
      .then((text) => {
        const case1Number = text.match(".*Case (.*)\n")[1]
        cy.getBySel("search-input")
          .type(case1Number)

        cy.getBySel("search-results")
          .findBySel("case-container")
          .should("have.length", 1)
          .should("contain", case1Number)
      })
    })
})
