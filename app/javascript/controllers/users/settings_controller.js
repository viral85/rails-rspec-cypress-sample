import { Controller } from "stimulus"
import StimulusReflex from "stimulus_reflex"
export default class extends Controller {
  static targets = [ "roleList",
                     "topicTitle", "topicForm", "topicEditBtn",
                     "topicInput", "topicCancel", "topicSave"
                   ]

  connect() {
    StimulusReflex.register(this)
    this.initializeSortable()
  }

  initializeSortable(){
    if (this.hasRoleListTarget){
      import("sortablejs").then((SortableModule) => {
        let Sortable = SortableModule.default
        Sortable.create(this.roleListTarget, {
          onEnd: this.updateList.bind(this)
        })
      })
    }
  }

  updateList(event){
    const element_id = event.item.dataset.roleId
    this.stimulate("settingsReflex#update_list", element_id,  event.newIndex + 1)
  }

  saveTopic(event){
    const newTitle = this.topicInputTarget.value
    if(newTitle == "" || !/\S/.test(newTitle)){
      return
    } else {
      let element = event.currentTarget
      element.disable = true
      element.classList.add("opacity-50")
      this.stimulate("SettingsReflex#save_topic", newTitle)
    }
  }

  validateTopicTitle(event){
    const topicTitle = event.target.value
    if(topicTitle == "" || !/\S/.test(topicTitle)){
      this.disableTopicForm()
    } else{
      this.enableTopicForm()
    }
  }

  disableTopicForm(){
    document.querySelector(".invalid-title-notice").classList.remove("hidden")
    this.topicSaveTarget.classList.add("opacity-50")
    this.topicSaveTarget.disabled = true
  }

  enableTopicForm(){
    if(document.getElementsByClassName("invalid-notice").length > 0){
      document.querySelector(".invalid-notice").classList.add("hidden")
    }
    document.querySelector(".invalid-title-notice").classList.add("hidden")
    this.topicSaveTarget.classList.remove("opacity-50")
    this.topicSaveTarget.disabled = false
  }

  topicEditMode(){
    this.topicFormTarget.classList.remove("hidden")
    this.topicTitleTarget.classList.add("hidden")
  }

  cancelTopicEditMode(){
    this.topicFormTarget.classList.add("hidden")
    this.topicTitleTarget.classList.remove("hidden")
  }

  showEditBtn(){
    this.topicEditBtnTarget.classList.remove("hidden")
  }

  hideEditBtn(){
    this.topicEditBtnTarget.classList.add("hidden")
  }
}
