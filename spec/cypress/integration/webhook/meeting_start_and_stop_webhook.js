describe("Zoom meeting Webhook", function(){

  beforeEach(function(){
    cy.app("clean")
      .then(() => cy.appFactories([["create", "organization","with_disable_cms"]]))
      .then(() => cy.appFactories([["create", "user"]]))
      .then(() => cy.appFactories([["create", "zoom_meeting"]]))
      .then(() => cy.appFactories([["create", "identity"]]))
      .then(() => cy.app("enable_webmock"))
      .then(() => cy.app("enable_sidekiq"))
      .then(() => cy.appStubs("get_meeting"))
      .then(() => cy.app("login"))
  })

  context("when user start meeting and end meeting from zoom", () => {
    it("show the meeting has start and ended", () => {    

      cy.visit("/panel")
      cy.getBySel("no-cases-message-container")
        .should("contain", "There are currently no cases with participants in the waiting room.")
      cy.request("post", "/zoom_webhooks",{ "event": "meeting.ended",
                                            "event_ts": Date.now(),    
                                            "payload": { "object": {
                                                        "id": "94446976353",
                                                        "host_id": "KdYKjnimT4KPd8FFgQt9FQ" }
                                                      }})
      cy.waitForStimlulusReflexToBeReady()
      cy.getBySel("panel-error-title")
        .should("contain", "The meeting has ended")
      cy.getBySel("panel-error-discription")
        .should("contain", "Close the control panel or start the Zoom meeting again "+
                           "if you would like the control panel to restart.")
      cy.getBySel("no-cases-message-container")
        .should("not.visible", "There are currently no cases "+
                               "with participants in the waiting room.")


      cy.request("post", "/zoom_webhooks",{ "event": "meeting.started",
        "event_ts": Date.now() + 1,
        "payload": { "object": {
                    "id": "94446976353",
                    "host_id": "KdYKjnimT4KPd8FFgQt9FQ" }
                  }})
      cy.waitForStimlulusReflexToBeReady()
      cy.getBySel("panel-error-title")
        .should("not.contain", "The meeting has ended")
      cy.getBySel("no-cases-message-container")
        .should("contain", "There are currently no cases with participants in the waiting room.")
    })
  })
})