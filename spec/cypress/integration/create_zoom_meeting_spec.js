describe("Create Zoom Meeting", function(){
  beforeEach(function(){
    cy.app("clean")
      .then(() => cy.appFactories([["create", "user"]]))
      .then(() => cy.appFactories([["create", "identity"]]))
      // .then(() => cy.app("enable_webmock"))
      // .then(() => cy.appStubs("no_zoom_meeting"))
      .then(() => cy.app("login"))
      .then(() => cy.visit("/"))
      // .then(() => cy.appStubs("create_zoom_meeting"))
  })

  it("create zoom meeting meeting was blank", () => {
    cy.getBySel("registration-room-url")
      .should('not.exist')

    
    cy.getBySel("create_zoom_meeting_btn")
      .should("contain", "Create Zoom Meeting")
    // cy.getBySel("create_zoom_meeting_btn")
    //   .click()
      
    // cy.getBySel("registration-room-url")
    //   .should("contain", "/r/123456")
  })

  // it("create meeting when meeting was ended", () => {
    // cy.appFactories([["create", "zoom_meeting"]])
  // TODO
  // })

  // it("create meeting when meeting not exist in zoom", () => {
    // cy.appFactories([["create", "zoom_meeting"]])
  // TODO 
  // })

})
