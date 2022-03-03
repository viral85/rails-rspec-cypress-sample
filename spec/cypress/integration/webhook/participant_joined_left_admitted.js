describe("Zoom meeting Webhook", function(){

  const case_number = "5DJJD22S1"

  const participant = {
    user_name: "John doe - Witness",
    email: "info+xrtnyzbgus8jgbmtpnrhnfg9@xyz.io",
    name: "John doe",
    phone: "+91 123-123-1234"
  }

  const meeting_id = "94446976353"
  const host_id = "KdYKjnimT4KPd8FFgQt9FQ"

  const meeting_payload = {
    object: { 
      participant: {
                      user_name: participant.user_name,
                      email: participant.email
                  },
      id: meeting_id, 
      host_id: host_id
      }                          
  }

  beforeEach(function(){
    cy.app("clean")
      .then(() => cy.appFactories([["create", "organization"]]))
      .then(() => cy.appFactories([["create", "user"]]))
      .then(() => cy.appFactories([["create", "zoom_meeting"]]))
      .then(() => cy.appFactories([["create", "identity"]]))
      .then(() => cy.app("enable_webmock"))
      .then(() => cy.app("enable_sidekiq"))
      .then(() => cy.appStubs("get_meeting"))
      .then(() => cy.appScenario("generate_case_with_participants",
        { case_number: case_number })
      )      
      .then(() => cy.app("login"))
  })
  context("when assigned participant joined and left via webhook", () => {
    it("show the participant on panel", () => {    
      cy.visit("/panel")
      
      cy.getBySel("in-waiting-room-counter")
        .should("contain", 3)

      cy.getBySel("participants-tab")
      .click()
      cy.getBySel("ungrouped-participants-counter")
        .should("contain", 0)
      cy.request("post", "/zoom_webhooks",
                        { "event": "meeting.participant_joined_waiting_room",
                          "event_ts": Date.now(),
                          "payload": meeting_payload
                        })
      cy.waitForStimlulusReflexToBeReady()

      cy.getBySel("ungrouped-participants-counter")
        .should("contain", 1)

      cy.getBySel("ungrouped-participant")
        .should("contain", participant.name)        
        .findBySel("assign-participant-input")
        .type(case_number)

      cy.getBySel("ungrouped-participant")
        .findBySel("assign-participant-btn")
        .click()
        .waitForStimlulusReflexToBeReady()
      cy.getBySel("ungrouped-participants-counter")
        .should("contain", 0)
      
      cy.getBySel("cases-tab")
        .click()
      cy.getBySel("in-waiting-room-counter")
        .should("contain", 4)
      
      cy.getBySel("blue-dot-indicator")
        .should("have.length", 4)                

      cy.getBySel("start-case-btn")
        .click()
        .waitForStimlulusReflexToBeReady()  
      // webhook Call participant_joined
      cy.request("post", "/zoom_webhooks",
                        { "event": "meeting.participant_joined",
                          "event_ts": Date.now() + 1,
                          "payload": meeting_payload
                        })
      cy.waitForStimlulusReflexToBeReady()  
      cy.getBySel("blue-dot-indicator")
        .should("have.length", 0)
      cy.getBySel("green-dot-indicator")
        .should("have.length", 1)
      cy.getBySel("loading-spinner")
        .should("have.length", 3)
      cy.getBySel("in-waiting-room-counter")
        .should("have.length", 0)                  
      cy.getBySel("in-meeting-room-counter")
        .should("contain", 4)
      // webhook call meeting.participant_put_in_waiting_room
      cy.request("post", "/zoom_webhooks",
                        { "event": "meeting.participant_put_in_waiting_room",
                          "event_ts": Date.now() + 2,
                          "payload": meeting_payload
                        })  
      cy.waitForStimlulusReflexToBeReady()
      cy.getBySel("in-meeting-room-counter")
        .should("contain", 3)
      cy.getBySel("in-waiting-room-counter")
        .should("contain", 1)
      cy.getBySel("blue-dot-indicator")
        .should("have.length", 1)
      cy.getBySel("loading-spinner")
        .should("have.length", 3)
      cy.getBySel("case-container")        
        .should("contain", participant.name)  
      // webhook Call participant_left 
      cy.request("post", "/zoom_webhooks",
        { "event": "meeting.participant_left",
          "event_ts": Date.now() + 3,
          "payload": meeting_payload
        })
      cy.waitForStimlulusReflexToBeReady()

      cy.getBySel("loading-spinner")
        .should("have.length", 3)
      cy.getBySel("case-container")        
        .should("not.contain", participant.name)
        
    })
  })
})