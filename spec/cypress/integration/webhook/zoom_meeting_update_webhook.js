describe("Zoom Webhook meeting.update", function(){

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

  context("when user edit the zoom meeting on zoom application", () => {
    it("update zoom meeting topic", () => {    

      cy.visit("/settings")

      cy.getBySel("topicTitle")
        .contains("topic name")
      cy.getBySel("topicTitle")
        .should("not.contain", "New Meeting Topic")

       // webhook call meeting.participant_joined_waiting_room
      cy.request("post", "/zoom_webhooks",
       { "event": "meeting.updated",
         "event_ts": Date.now(),
         "payload":
          { "account_id": "qso9BrrZRPC2_KdVHJTGMg",
            "operator": "viral@xyz.io",
            "operator_id": "KdYKjnimT4KPd8FFgQt9FQ",
            "scope": "all",
            "object": { "id": 94_446_976_353, "topic": "New Meeting Topic", "password": "228899"},
            "old_object": { "id": 94_446_976_353, "topic": "Jane Dev", "password": "228885"},
            "time_stamp": Date.now()
          }          
       })
      cy.waitForStimlulusReflexToBeReady()
      cy.visit("/settings")
      cy.getBySel("topicTitle")
        .should("not.contain", "topic name")
      cy.getBySel("topicTitle")
        .contains("New Meeting Topic")
    })
  })
})