import { Controller } from "stimulus"
import StimulusReflex from "stimulus_reflex"

export default class extends Controller {
  static targets = [ "roleInfo", "roleForm", "roleEditBtn",
                     "roleDeleteBtn", "roleCancel", "roleSave",
                     "text", "spanishText",  "invalidNotice",
                     "addRoleBtn"
                   ]

  connect() {
    StimulusReflex.register(this)
    this.setFormState()
  }

  newRole(event){
    event.preventDefault()
    this.addRoleBtnTarget.classList.add("hidden")
    this.roleFormTarget.classList.remove("hidden")
  }

  setFormState(){
    if(this.textTarget.value == ""){
      this.roleSaveTarget.classList.add("opacity-50")
      this.roleSaveTarget.disabled = true
    } else {
      this.roleSaveTarget.classList.remove("opacity-50")
      this.roleSaveTarget.disabled = false
    }
  }

  saveRole(event){
    const roleObj = {}
    roleObj.roleId = event.currentTarget.dataset.roleId
    roleObj.text = this.textTarget.value.trim()
    roleObj.spanishText = this.spanishTextTarget.value
    if(roleObj.text == "" || !/\S/.test(roleObj.text))
      return

    let element = event.currentTarget
    element.disabled = true
    element.classList.add("opacity-50")
    this.stimulate("settingsReflex#save_role", roleObj)
  }

  createRole(event){
    const roleObj = {}
    roleObj.text = this.textTarget.value.trim()
    roleObj.spanishText = this.spanishTextTarget.value
    if(roleObj.text == "" || !/\S/.test(roleObj.text))
      return

    let element = event.currentTarget
    element.setAttribute("disabled", "")
    element.disabled = true
    element.classList.add("opacity-50")
    this.stimulate("settingsReflex#create_role", roleObj)
  }

  validateRole(event){
    this.invalidNoticeTarget.innerText = ""
    const role = event.target.value
    if(role == "" || !/\S/.test(role)){
      this.disableRoleForm()
    } else{
      this.enableRoleForm()
    }
  }

  disableRoleForm(){
    this.invalidNoticeTarget.innerText = "English Role cannot be blank"
    this.roleSaveTarget.classList.add("opacity-50")
    this.roleSaveTarget.disabled = true
  }

  enableRoleForm(){
    // this.invalidNoticeTarget.classList.add("hidden")
    this.roleSaveTarget.classList.remove("opacity-50")
    this.roleSaveTarget.disabled = false
  }

  deleteRole(event){
    if (confirm('Are you sure you want to delete this role?')) {
       this.stimulate("SettingsReflex#delete_role", this.element.dataset.roleId)
           .then(payload => {
             location.reload()
           })
     }
  }

  roleEditMode(){
    this.roleFormTarget.classList.remove("hidden")
    this.roleInfoTarget.classList.add("hidden")
  }

  cancelRoleEditMode(){
    if(this.element.dataset.newRole == "true"){
      // this.element.classList.add('transform', 'opacity-0', 'transition', 'duration-400')
      //setTimeout(() => this.element.remove(), 400)
      this.addRoleBtnTarget.classList.remove("hidden")
      this.roleFormTarget.classList.add("hidden")
      this.textTarget.value = ""
      this.spanishTextTarget.value = ""
    } else {
      this.textTarget.value = this.element.dataset.text
      this.spanishTextTarget.value = this.element.dataset.spanishText
      this.invalidNoticeTarget.innerText = ""
      this.roleFormTarget.classList.add("hidden")
      this.roleInfoTarget.classList.remove("hidden")
    }
  }
}
