describe("Add Multiple participants", function(){  

  const case_number = "5DJJD22S1"
  const new_case_number = "5DJJD22S2"

  beforeEach(function(){
    cy.app("clean")
      .then(() => cy.appFactories([["create", "user"]]))
      .then(() => cy.appFactories([["create", "zoom_meeting"]]))
      .then(() => cy.appFactories([["create", "identity"]]))
      .then(() => cy.app("enable_webmock"))
      .then(() => cy.appStubs("get_meeting"))
      .then(() => cy.appScenario("generate_case_with_participants",
        { case_number: case_number })
      )
      .then(() => cy.appScenario("generate_participants_without_case",
        { number_of_participants: "5" })
      )
      .then(() => cy.app("login"))
      .then(() => cy.visit("/panel/"))
      .then(() => cy.waitForStimlulusReflexToBeReady())
  })

  it("Assign multiple participant to existing upcoming case", () => {

    cy.getUpcomingCase(0)
      .findBySel("participants-list-container")
      .findBySel("participant")
      .should("have.length", 3) 

    cy.getBySel("participants-tab")
      .click()
    
    cy.getBySel("ungrouped-participants-counter")
      .should("contain", 5)

    cy.getBySel("ungrouped-participant")
      .findBySel("assign-participant-input")
      .should("have.length", 5)
      .last()
      .type(case_number)
    
    cy.getBySel("ungrouped-participant")
      .findBySel("assign-participant-btn")
      .last()
      .click()
      .waitForStimlulusReflexToBeReady()
    
    cy.getBySel("ungrouped-participant")
      .findBySel("assign-participant-input")
      .should("have.length", 4)
      .last()
      .type(case_number)
    
    cy.getBySel("ungrouped-participant")
      .findBySel("assign-participant-btn")
      .last()
      .click()  
      .waitForStimlulusReflexToBeReady()

    
    cy.getBySel("ungrouped-participant")
      .findBySel("assign-participant-input")
      .should("have.length", 3)
      .last()
      .type(case_number)
    
    cy.getBySel("ungrouped-participant")
      .findBySel("assign-participant-btn")
      .last()
      .click()
      .waitForStimlulusReflexToBeReady()
    
    cy.getBySel("cases-tab")
      .click()

    cy.getUpcomingCase(0)
      .findBySel("participants-list-container")
      .findBySel("participant")
      .should("have.length", 6)  
  })

  it("Assign multiple participants to new case", () => {
    cy.getUpcomingCase(0)
      .findBySel("participants-list-container")
      .findBySel("participant")
      .should("have.length", 3) 
  
    cy.getBySel("participants-tab")
      .click()
    
    cy.getBySel("ungrouped-participants-counter")
      .should("contain", 5)

    cy.getBySel("ungrouped-participant")
      .findBySel("assign-participant-input")
      .should("have.length", 5)
      .last()
      .type(new_case_number)
    
    cy.getBySel("ungrouped-participant")
      .findBySel("assign-participant-btn")
      .last()
      .click()
      .waitForStimlulusReflexToBeReady()
    
    cy.getBySel("ungrouped-participant")
      .findBySel("assign-participant-input")
      .should("have.length", 4)
      .last()
      .type(new_case_number)
    
    cy.getBySel("ungrouped-participant")
      .findBySel("assign-participant-btn")
      .last()
      .click()  
      .waitForStimlulusReflexToBeReady()

    
    cy.getBySel("ungrouped-participant")
      .findBySel("assign-participant-input")
      .should("have.length", 3)
      .last()
      .type(new_case_number)
    
    cy.getBySel("ungrouped-participant")
      .findBySel("assign-participant-btn")
      .last()
      .click()
      .waitForStimlulusReflexToBeReady()
    
    cy.getBySel("ungrouped-participant")
      .findBySel("assign-participant-input")
      .should("have.length", 2)
      .last()
      .type(new_case_number)
    
    cy.getBySel("ungrouped-participant")
      .findBySel("assign-participant-btn")
      .last()
      .click()
      .waitForStimlulusReflexToBeReady()  
    
    cy.getBySel("cases-tab")
      .click()

    cy.getUpcomingCase(0)
      .findBySel("participants-list-container")
      .findBySel("participant")
      .should("have.length", 3)

    cy.getUpcomingCase(1)
      .findBySel("participants-list-container")
      .findBySel("participant")
      .should("have.length", 4)
      
    cy.getBySel("ungrouped-participant")
      .findBySel("assign-participant-input")
      .should("have.length", 1)
    
    cy.get("[data-cy=upcoming-cases]")
      .find("[data-cy=case-container]")
      .should("be.have.length", 2)  
  })

  it("Assign multiple participants to active case", () => {
    cy.getUpcomingCase(0)
      .findBySel("participants-list-container")
      .findBySel("participant")
      .should("have.length", 3) 
    
    cy.getBySel("start-case-btn")
      .click()
      .waitForStimlulusReflexToBeReady()
  
    cy.getBySel("participants-tab")
      .click()
    
    cy.getBySel("ungrouped-participants-counter")
      .should("contain", 5)
    
    cy.getBySel("ungrouped-participant")
      .findBySel("assign-participant-input")
      .should("have.length", 5)
      .last()
      .type(case_number)
    
    cy.getBySel("ungrouped-participant")
      .findBySel("assign-participant-btn")
      .last()
      .click()
      .waitForStimlulusReflexToBeReady()
    
    cy.getBySel("ungrouped-participant")
      .findBySel("assign-participant-input")
      .should("have.length", 4)
      .last()
      .type(case_number)
    
    cy.getBySel("ungrouped-participant")
      .findBySel("assign-participant-btn")
      .last()
      .click()  
      .waitForStimlulusReflexToBeReady()

    
    cy.getBySel("ungrouped-participant")
      .findBySel("assign-participant-input")
      .should("have.length", 3)
      .last()
      .type(case_number)
    
    cy.getBySel("ungrouped-participant")
      .findBySel("assign-participant-btn")
      .last()
      .click()
      .waitForStimlulusReflexToBeReady()
    
    cy.getBySel("ungrouped-participant")
      .findBySel("assign-participant-input")
      .should("have.length", 2)
      .last()
      .type(case_number)
    
    cy.getBySel("ungrouped-participant")
      .findBySel("assign-participant-btn")
      .last()
      .click()
      .waitForStimlulusReflexToBeReady()  
    
    cy.getBySel("cases-tab")
      .click()
      .waitForStimlulusReflexToBeReady() 

    cy.getActiveCase()
      .findBySel("participants-list-container")
      .findBySel("participant")
      .should("have.length", 7)
  })
})
