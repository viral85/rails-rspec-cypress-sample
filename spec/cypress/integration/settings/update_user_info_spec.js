describe("Update User information", function(){
  beforeEach(function(){
    cy.app("clean")
      .then(() => cy.appFactories([["create", "user"]]))
      .then(() => cy.appFactories([["create", "zoom_meeting"]]))
      .then(() => cy.appFactories([["create", "identity"]]))
      .then(() => cy.app("enable_webmock"))
      .then(() => cy.appStubs("update_meeting_topic"))
      .then(() => cy.app("login"))
      .then(() => cy.viewport(1090,860))
      .then(() => cy.visit("/settings"))
  })

  it("Copy the registration link", () => {
   
    cy.getBySel("copy-registration-link")
      .click()
        
    cy.getBySel("registration-room-url")
      .contains("Copied!")  
   
  })

  it("Update meeting topic", () => {
    const topic_name = "New Test Topic"

    cy.getBySel("topic-edit-btn")
      .click()
    
    cy.getBySel("topic-input")
      .click()
      .clear()
      .type(topic_name)
      
    cy.getBySel("topic-update-btn")
      .should("have.length", 1)
      .click()

    cy.visit("/settings")  
    cy.getBySel("topicTitle")      
      .contains("New Test Topic")  
  })
})
