import { Controller } from "stimulus"
import StimulusReflex from "stimulus_reflex"
import debounced from "debounced"

export default class extends Controller {
  static targets = ["gallery", "imageTemplate", "changeLogoBtn", "uploadLogoForm",
                    "logoField", "removeLogoForm", "initialLogo", "invalidNotice"]
  static values = { removeLogoMessage: String }

  connect(){
    StimulusReflex.register(this)
    debounced.initialize({ input: { wait: 500 } })
  }

  addToPreview(target, file) {    
    const clone = this.imageTemplateTarget.content.cloneNode(true)
    Object.assign(clone.querySelector("img"), {
      src: URL.createObjectURL(file),
    })
    this.initialLogoTarget.classList.add("hidden")
    target.prepend(clone)
  }

  openFileUploder(event){
    this.invalidNoticeTarget.innerText = ""
    this.logoFieldTarget.click()
  }

  previewLogo(event){    
    for (const file of event.target.files) {      
      this.validLogo(file)
    }
  }

  validLogo(file){
    if (file.type.match("image.*") != null && Math.round(file.size/1024/1024)<=10 ){
      this.disableChangeLogoButton()
      this.uploadLogo()
      this.addToPreview(this.galleryTarget, file)
    }else{
      this.invalidNoticeTarget.innerText = "Please upload an image smaller than 10 MB."
    }
  }

  RemoveCurrentImage(event){
    if (confirm(this.removeLogoMessageValue)){
      this.disableChangeLogoButton()
      this.removeLogoFormTarget.submit()
    }
  }

  disableChangeLogoButton(){
    this.changeLogoBtnTarget.classList.add("opacity-50")
    this.changeLogoBtnTarget.classList.add("pointer-events-none")
    this.changeLogoBtnTarget.innerText = "Changing your logo..."
    this.galleryTarget.classList.add("pointer-events-none")
    this.galleryTarget.classList.add("opacity-50")
  }

  uploadLogo(){
    this.uploadLogoFormTarget.submit()
  }
}
