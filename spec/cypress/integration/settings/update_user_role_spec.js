describe("Update User Roles", function(){
  beforeEach(function(){
    cy.app("clean")
      .then(() => cy.appFactories([["create", "user"]]))
      .then(() => cy.appFactories([["create", "zoom_meeting"]]))
      .then(() => cy.appFactories([["create", "identity"]]))
      .then(() => cy.app("enable_webmock"))
      .then(() => cy.app("login"))
      .then(() => cy.viewport(1090,860))
      .then(() => cy.visit("/settings"))
  })

  it("Role not displayed on your registration page", () => {
    cy.getBySel("rolesErrorMessage")
      .should("not.exist")

    cy.getBySel("roleList")
      .last()
      .findBySel("roleDeleteBtn")
      .last()
      .click()
      .waitForStimlulusReflexToBeReady()

    cy.getBySel("roleList")
      .should("not.have.length", 3)
      .wait(2000)

    cy.getBySel("rolesErrorMessage")
      .should("contain", "Your roles are not being displayed on your registration page")
    // TODO for remove msg
  })

  it("Delete existing role", () => {

    cy.getBySel("roleList")
      .children()
      .should("have.length", 3)
      .wait(2000)

    cy.getBySel("roleList")
      .last()
      .findBySel("roleDeleteBtn")
      .last()
      .click()
      .waitForStimlulusReflexToBeReady()

    cy.getBySel("roleList")
      .children()
      .should("have.length", 2)

    cy.visit("/settings")

    cy.getBySel("roleList")
      .children()
      .should("have.length", 2)

  })

  it("Create new role", () => {
    cy.getBySel("roleList")
      .children()
      .should("have.length", 3)

    cy.getBySel("addRoleBtn")
      .click()

    cy.getBySel("englishRoleText")
      .last()
      .clear()
      .should("have.value", "")

    cy.getBySel("englishRoleText")
      .last()
      .clear()
      .type("a")

    cy.getBySel("englishRoleText")
      .last()
      .clear()

    cy.getBySel("role-text-english-error-msg")
      .should("contain", "English Role cannot be blank")

    cy.getBySel("roleSave")
      .last()
      .click({force: true})
      .waitForStimlulusReflexToBeReady()


    cy.getBySel("englishRoleText")
      .last()
      .clear()
      .type("Witness")

    cy.getBySel("roleSave")
      .last()
      .click({force: true})
      .waitForStimlulusReflexToBeReady()

    cy.getBySel("role-text-english-error-msg")
      .should("contain", "Role should be unique")

    cy.getBySel("englishRoleText")
      .last()
      .clear()
      .type("Testing Witnesses")

    cy.getBySel("spanishRoleText")
      .last()
      .type("Testigos de prueba")

    cy.getBySel("roleSave")
      .last()
      .click()
      .waitForStimlulusReflexToBeReady()

    cy.getBySel("roleList")
      .children()
      .should("have.length", 4)

    cy.visit("/settings")

    cy.getBySel("roleList")
      .children()
      .should("have.length", 4)
  })

  it("Update existing role", () => {
    cy.getBySel("roleList")
      .findBySel("roleEditForm")
      .first()
      .click({force: true})

    cy.getBySel("englishRoleText")
      .first()
      .clear()

    cy.getBySel("role-text-english-error-msg")
      .should("contain", "English Role cannot be blank")

    cy.getBySel("englishRoleText")
      .first()
      .type("Witness")

    cy.getBySel("roleSave")
      .first()
      .click({force: true})
      .waitForStimlulusReflexToBeReady()

    cy.getBySel("role-text-english-error-msg")
      .should("contain", "Role should be unique")

    cy.getBySel("englishRoleText")
      .first()
      .clear()
      .type("Test Prosecuting Attorney xyzRole")

    cy.getBySel("spanishRoleText")
      .first()
      .clear()
      .type("Abogada fiscal")

    cy.getBySel("roleSave")
      .first()
      .click({force: true})
      .waitForStimlulusReflexToBeReady()

    cy.getBySel("role-text-english-error-msg")
      .should("not.contain", "Role should be unique")

    cy.visit("/settings")

    cy.getBySel("roleList")
      .should("contain", "Test Prosecuting Attorney xyzRole")
  })

})
