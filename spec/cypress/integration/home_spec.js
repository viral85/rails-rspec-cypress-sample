describe("Home page", function(){
  beforeEach(function(){
    cy.app("clean")
      .then(() => cy.appFactories([["create", "user"]]))
      .then(() => cy.appFactories([["create", "zoom_meeting"]]))
      .then(() => cy.appFactories([["create", "identity"]]))
      .then(() => cy.app("enable_webmock"))
      .then(() => cy.appStubs("get_meeting"))
      .then(() => cy.app("login"))
  })

  context("when user has identity and zoom_meeting", () => {
    it("shows meeting id", () => {
      const meetingId = "94446976353"

      cy.visit("/")
      cy.getBySel("zoom_meeting_id")
        .should("contain", meetingId )
    })

    it("sign out the user", () => {      
      cy.visit("/")
      cy.getBySel("home-menu")
        .click()
      cy.getBySel("sign-out")
        .click()
      cy.getBySel("notification")
        .should("contain", "Signed out successfully.")
    })
  })
})
