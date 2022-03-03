describe("Zoom meeting Webhook", function(){

  const case_number = "5DJJD22S1"

  const ungrouped_participant = {
    first_name: "Von",
    last_name: "Chow",
    name: "Von Chow"
  }

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

  const meeting_payload_with_phone = {
    object: {
      participant: {
                      user_name: participant.phone,
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
      .then(() => cy.appScenario("generate_participant_without_case",
        { first_name: ungrouped_participant.first_name,
          last_name: ungrouped_participant.last_name
        })
      )
      .then(() => cy.app("login"))
  })

  context("when participant joined and left waiting room", () => {
    it("show the participant on panel", () => {

      cy.visit("/panel")
      cy.getBySel("ungrouped-participant")
        .should("have.length", 1)

      // webhook call meeting.participant_joined_waiting_room
      cy.request("post", "/zoom_webhooks",
                        { "event": "meeting.participant_joined_waiting_room",
                          "event_ts": Date.now(),
                          "payload": meeting_payload
                        })
      cy.waitForStimlulusReflexToBeReady()
      // check participant will show on panel
      cy.getBySel("participants-tab")
        .click()
      cy.getBySel("ungrouped-participant")
        .should("have.length", 2)
      cy.getBySel("ungrouped-participant")
        .should("contain", participant.name)

      // webhook call  meeting.participant_left_waiting_room
      cy.request("post", "/zoom_webhooks",
        { "event": "meeting.participant_left_waiting_room",
          "event_ts": Date.now() + 1,
          "payload": meeting_payload
        })
      cy.waitForStimlulusReflexToBeReady()
      // check that participant removed from panel
      cy.getBySel("ungrouped-participant")
        .should("have.length", 1)
      cy.getBySel("ungrouped-participant")
        .should("not.contain", participant.name)
      cy.getBySel("ungrouped-participant")
        .should("contain", ungrouped_participant.name)
    })
  })

  context("when participant joined and left", () => {
    it("show the participant on panel", () => {

      cy.visit("/panel")
      cy.getBySel("ungrouped-participant")
        .should("have.length", 1)
      cy.getBySel("participants-tab")
        .click()
      // webhook call meeting.participant_joined_waiting_room
      cy.request("post", "/zoom_webhooks",
                        { "event": "meeting.participant_joined_waiting_room",
                          "event_ts": Date.now(),
                          "payload": meeting_payload
                        })
      cy.waitForStimlulusReflexToBeReady()
      // check there is 2 ungrouped-participant
      cy.getBySel("ungrouped-participant")
        .should("have.length", 2)
      cy.getBySel("ungrouped-participant")
        .should("contain", participant.name)
      cy.getBySel("active-ungrouped-participant")
        .should("have.length", 0)
      cy.getBySel("active-ungrouped-participant")
        .should("not.exist")

      // webhook Call participant_joined
      cy.request("post", "/zoom_webhooks",
                        { "event": "meeting.participant_joined",
                          "event_ts": Date.now() + 1,
                          "payload": meeting_payload
                        })
      cy.waitForStimlulusReflexToBeReady()
      // check that participant is added to active group
      cy.getBySel("ungrouped-participant")
        .should("have.length", 1)
      cy.getBySel("ungrouped-participant")
        .should("not.contain", participant.name)

        cy.getBySel("active-ungrouped-participant")
        .should("contain", participant.name)
      cy.getBySel("active-ungrouped-participant")
        .should("contain", "Witness")
      cy.getBySel("active-ungrouped-participant")
        .should("contain", "In the meeting")
      cy.getBySel("active-ungrouped-participant")
        .should("have.length", 1)

      // webhook call meeting.participant_put_in_waiting_room
      cy.request("post", "/zoom_webhooks",
                        { "event": "meeting.participant_put_in_waiting_room",
                          "event_ts": Date.now() + 2,
                          "payload": meeting_payload
                        })
      cy.waitForStimlulusReflexToBeReady()
      // check participant removed from meeting
      cy.getBySel("ungrouped-participant")
        .should("have.length", 2)
      cy.getBySel("ungrouped-participant")
        .should("contain", participant.name)

      cy.getBySel("active-ungrouped-participant")
        .should("have.length", 0)
      // webhook Call participant_left
      cy.request("post", "/zoom_webhooks",
                        { "event": "meeting.participant_left",
                          "event_ts": Date.now() + 3,
                          "payload": meeting_payload
                        })
      cy.waitForStimlulusReflexToBeReady()
      // check that participant was removed panel
      cy.getBySel("ungrouped-participant")
        .should("have.length", 1)
      cy.getBySel("ungrouped-participant")
        .should("not.contain", participant.name)
      cy.getBySel("active-ungrouped-participant")
        .should("have.length", 0)
    })
  })

  context("when participant admitted via phone number", () => {
    it("show the participant on panel", () => {
      cy.visit("/panel")
      // check that participant is not on panel
      cy.getBySel("ungrouped-participant")
        .should("have.length", 1)
      cy.getBySel("ungrouped-participant")
        .should("not.contain", "John doe")
      cy.getBySel("participants-tab")
        .click()
      // webhook call meeting.participant_admitted
      cy.request("post", "/zoom_webhooks",
                        { "event": "meeting.participant_admitted",
                          "event_ts": Date.now(),
                          "payload": meeting_payload_with_phone
                        })
      cy.waitForStimlulusReflexToBeReady()
      // check participant will show on panel
      cy.getBySel("ungrouped-participant")
        .should("have.length", 2)
      cy.getBySel("ungrouped-participant")
        .should("contain", participant.phone)
    })
  })
  context("when participant joined and left waiting room vai phone", () => {
    it("show the participant on panel", () => {

      cy.visit("/panel")

      cy.getBySel("participants-tab")
        .click()

      cy.getBySel("ungrouped-participant")
        .should("have.length", 1)

      // webhook call meeting.participant_joined_waiting_room
      cy.request("post", "/zoom_webhooks",
                        { "event": "meeting.participant_joined_waiting_room",
                          "event_ts": Date.now(),
                          "payload": meeting_payload_with_phone
                        })
        .waitForStimlulusReflexToBeReady()
      // check participant will show on panel

      cy.getBySel("ungrouped-participant")
        .should("have.length", 2)
      cy.getBySel("ungrouped-participant")
        .should("contain", participant.phone)

      // webhook call  meeting.participant_left_waiting_room
      cy.request("post", "/zoom_webhooks",
        { "event": "meeting.participant_left_waiting_room",
          "event_ts": Date.now() + 1,
          "payload": meeting_payload_with_phone
        })
      cy.waitForStimlulusReflexToBeReady()
      // check that participant removed from panel
      cy.getBySel("ungrouped-participant")
        .should("have.length", 1)
      cy.getBySel("ungrouped-participant")
        .should("not.contain", participant.phone)
      cy.getBySel("ungrouped-participant")
        .should("contain", ungrouped_participant.name)
    })
  })
})
