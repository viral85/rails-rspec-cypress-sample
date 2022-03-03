describe("Assign and unassing participants", function(){
  const ungrouped_participant = {
    first_name: "John",
    last_name: "Doe"
  }

  const full_name = `${ungrouped_participant.first_name} ${ungrouped_participant.last_name}`

  const case_number = "5DJJD22S1"


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
      .then(() => cy.appScenario("generate_participant_without_case",
        { first_name: ungrouped_participant.first_name,
          last_name: ungrouped_participant.last_name
        })
      )
      .then(() => cy.app("login"))
      .then(() => cy.visit("/panel/"))
      .then(() => cy.waitForStimlulusReflexToBeReady())
  })

  it("assings to existing upcoming case", () => {
    cy.getUpcomingCase(0)
      .findBySel("toggle-participants-list-btn")
      .should("be.visible")
      .click()
      .waitForStimlulusReflexToBeReady()

    cy.getUpcomingCase(0)
      .findBySel("participants-list-container")
      .findBySel("participant")
      .should("have.length", 3)

    cy.getBySel("participants-tab")
      .click()

    cy.getBySel("ungrouped-participant")
      .should("contain", full_name)
      .findBySel("assign-participant-input")
      .type(case_number)

    cy.getBySel("ungrouped-participant")
      .findBySel("assign-participant-btn")
      .click()

    cy.getBySel("ungrouped-participant")
      .should("have.length", 0)

    cy.getBySel("ungrouped-participants-counter")
      .should("contain", 0)

    cy.getBySel("cases-tab")
      .click()

    cy.getUpcomingCase(0)
      .findBySel("participants-list-container")
      .findBySel("participant")
      .should("have.length", 4)
      .last()
      .should("contain", full_name)
  })

  it("assings to a new case", () => {
    cy.getBySel("participants-tab")
      .click()

    cy.getBySel("participants-tab")
      .click()

    const new_case_number = "H7H4JK9EE"

    cy.getBySel("ungrouped-participant")
      .should("contain", full_name)
      .findBySel("assign-participant-input")
      .type(new_case_number)

    cy.getBySel("ungrouped-participant")
      .findBySel("assign-participant-btn")
      .click()

    cy.getBySel("ungrouped-participant")
      .should("have.length", 0)

    cy.getBySel("ungrouped-participants-counter")
      .should("contain", 0)

    cy.getBySel("cases-tab")
      .click()

    cy.getUpcomingCase(1)
      .findBySel("case-number")
      .should("contain", new_case_number)

    cy.getUpcomingCase(1)
      .findBySel("toggle-participants-list-btn")
      .should("be.visible")
      .click()
      .waitForStimlulusReflexToBeReady()

    cy.getUpcomingCase(1)
      .findBySel("participants-list-container")
      .findBySel("participant")
      .should("have.length", 1)
      .first()
      .should("contain", full_name)
  })

  it("adds ungrouped participant to the meeting and removes from", () => {
    cy.getBySel("participants-tab")
      .click()

    cy.getBySel("ungrouped-participant")
      .should("have.length", 1)
      .findBySel("participant-dropdown")
      .click()

    cy.getBySel("ungrouped-participant")
      .findBySel("add-ungrouped-participant-btn")
      .click()
      .waitForStimlulusReflexToBeReady()

    cy.getBySel("ungrouped-participant")
      .should("have.length", 0)

    cy.getBySel("active-ungrouped-participant")
      .should("have.length", 1)
      .should("contain", full_name)
      .findBySel("participant-dropdown")
      .click()

    cy.getBySel("active-ungrouped-participant")
      .findBySel("put-waiting-ungrouped-participant")
      .click()
      .waitForStimlulusReflexToBeReady()

    cy.getBySel("active-ungrouped-participant")
      .should("have.length", 0)

    cy.getBySel("ungrouped-participant")
      .should("have.length", 1)
  })

  it("unassing participant from upcoming case", () => {
    cy.getBySel("ungrouped-participants-counter")
      .should("contain", 1)

    cy.getUpcomingCase(0)
      .findBySel("toggle-participants-list-btn")
      .should("be.visible")
      .click()
      .waitForStimlulusReflexToBeReady()

    cy.getUpcomingCase(0)
      .findBySel("participant")
      .should("have.length", 3)
      .last()
      .findBySel("participant-dropdown")
      .click()

    cy.getUpcomingCase(0)
      .findBySel("participant")
      .should("have.length", 3)
      .last()
      .findBySel("unassign-participant")
      .click()

    cy.getUpcomingCase(0)
      .findBySel("participant")
      .should("have.length", 2)

    cy.getUpcomingCase(0)
      .findBySel("participants-count")
      .should("contain", 2)

    cy.getBySel("ungrouped-participants-counter")
      .should("contain", 2)

    cy.getBySel("participants-tab")
      .click()

    cy.getBySel("ungrouped-participant")
      .should("have.length", 2)
  })

  // TODO specs to enhance the coverage
  it("unassign participant from active case", () => {
    // NOTE participant should placed into ungrouped participants and moved to waiting room

    cy.getBySel("ungrouped-participants-counter")
      .should("contain", 1)

    cy.getBySel("start-case-btn")
      .click()
      .waitForStimlulusReflexToBeReady()

    cy.getActiveCase()
      .findBySel("participants-list-container")
      .findBySel("participant")
      .eq(1)
      
    cy.getActiveCase()
      .findParticipant(0)
      .findBySel("participant-dropdown")
      .click()

    cy.getActiveCase()
      .findParticipant(0)
      .findBySel("unassign-participant")
      .click()
      .waitForStimlulusReflexToBeReady()
    
    cy.getBySel("ungrouped-participants-counter")
      .should("contain", 2)    
  })

  it("assings to existing active case", () => {
    // NOTE participant should be added to waiting room
    cy.getBySel("ungrouped-participants-counter")
      .should("contain", 1)

    cy.getBySel("start-case-btn")
      .click()
      .waitForStimlulusReflexToBeReady()
    
    cy.getBySel("participants-tab")
      .click()

    const active_case_number = "5DJJD22S1"

    cy.getBySel("ungrouped-participant")
      .should("contain", full_name)
      .findBySel("assign-participant-input")
      .type(active_case_number)

    cy.getBySel("ungrouped-participant")
      .findBySel("assign-participant-btn")
      .click()
      .waitForStimlulusReflexToBeReady()
    
    cy.getBySel("ungrouped-participants-counter")
      .should("contain", 0)  
  })

  it("admit participant to the meeting and assigns to active case", () => {
    // NOTE participant should be added to waiting room
    cy.getBySel("ungrouped-participants-counter")
      .should("contain", 1)

    cy.getBySel("start-case-btn")
      .click()
      .waitForStimlulusReflexToBeReady()
    
    cy.getBySel("more-info-dropdown")
      .click()
    
    cy.getBySel("admit-all-btn")
      .click()
      .waitForStimlulusReflexToBeReady()

    cy.getBySel("in-meeting-room-counter")
      .should("contain", 3)

    cy.getBySel("participants-tab")
      .click()

    const active_case_number = "5DJJD22S1"

    cy.getBySel("ungrouped-participant")
      .should("contain", full_name)
      .findBySel("assign-participant-input")
      .type(active_case_number)

    cy.getBySel("ungrouped-participant")
      .findBySel("assign-participant-btn")
      .click()
      .waitForStimlulusReflexToBeReady()

    cy.getBySel("cases-tab")
      .click()

    cy.getBySel("participants-list-container")
      .findBySel("participant").last()
      .eq(0)
      .findBySel("participant-dropdown")
      .click()

    cy.getBySel("add-participant-btn")
      .click()
      .waitForStimlulusReflexToBeReady()
    
    cy.getBySel("in-meeting-room-counter")
      .should("contain", 4)  
  })

  it("admit participant to the meeting and assigns to upcoming case", () => {
    // NOTE participant should be added to waiting room
    cy.getUpcomingCase(0)
      .findBySel("toggle-participants-list-btn")
      .should("be.visible")
      .click()
      .waitForStimlulusReflexToBeReady()
    
    cy.getBySel("more-info-dropdown")
      .click()
    
    cy.getBySel("admit-all-btn")
      .click()
      .waitForStimlulusReflexToBeReady()
    
    cy.getBySel("in-meeting-room-counter")
      .should("contain", 3)
    
      cy.getBySel("participants-tab")
      .click()

    const active_case_number = "5DJJD22S1"

    cy.getBySel("ungrouped-participant")
      .should("contain", full_name)
      .findBySel("assign-participant-input")
      .type(active_case_number)

    cy.getBySel("ungrouped-participant")
      .findBySel("assign-participant-btn")
      .click()
      .waitForStimlulusReflexToBeReady()

    cy.getBySel("cases-tab")
      .click()

    cy.getBySel("participants-list-container")
      .findBySel("participant").last()
      .eq(0)
      .findBySel("participant-dropdown")
      .click()

    cy.getBySel("add-participant-btn")
      .click()
      .waitForStimlulusReflexToBeReady()
    
    cy.getBySel("in-meeting-room-counter")
      .should("contain", 4)  
  })
})
