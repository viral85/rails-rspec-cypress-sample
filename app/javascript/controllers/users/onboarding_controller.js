import { Controller } from "stimulus"
import StimulusReflex from "stimulus_reflex"

export default class extends Controller {
  static targets = ["step1Body", "step2Body", "step3Body",
                    "step1Container", "step2Container", "step3Container",
                    "step1Toggler", "step2Toggler", "step3Toggler",
                    "step1Number", "step2Number", "step3Number",
                    "step1Checkmark", "step2Checkmark", "step3Checkmark",
                    "step1Header", "step2Header", "step3Header",
                    "step1CompleteBtn", "step2CompleteBtn", "step3CompleteBtn"]

  step1 = null
  step2 = null
  step3 = null

  connect() {
    StimulusReflex.register(this)
    this.step1 = {
      body: this.step1BodyTarget,
      container: this.step1ContainerTarget,
      toggler: this.step1TogglerTarget,
      number: this.step1NumberTarget,
      checkmark: this.step1CheckmarkTarget,
      header: this.step1HeaderTarget,
      completeBtn: this.step1CompleteBtnTarget
    }

    this.step2 = {
      body: this.step2BodyTarget,
      container: this.step2ContainerTarget,
      toggler: this.step2TogglerTarget,
      number: this.step2NumberTarget,
      checkmark: this.step2CheckmarkTarget,
      header: this.step2HeaderTarget,
      completeBtn: this.step2CompleteBtnTarget
    }

    this.step3 = {
      body: this.step3BodyTarget,
      container: this.step3ContainerTarget,
      toggler: this.step3TogglerTarget,
      number: this.step3NumberTarget,
      checkmark: this.step3CheckmarkTarget,
      header: this.step3HeaderTarget,
      completeBtn: this.step3CompleteBtnTarget
    }
  }

  completeStep(event) {
    const element = event.currentTarget
    const currentStepNumber = this.stepNumberFrom(element)

    this.stimulate("OnboardingReflex#complete_step", element)
        .then(() => {
          this.setStepAsCompleted(currentStepNumber)
          if (this.isAllStepsCompleted()) this.finalizeOnboarding()
        })
    this.toggleStep(currentStepNumber)
    const nextStepNumber = currentStepNumber + 1
    if (!this.isStepOpened(nextStepNumber)) this.toggleStep(nextStepNumber)
  }

  stepNumberFrom(element) {
    return parseInt(element.dataset.step_number)
  }

  finalizeOnboarding() {
    window.location.replace("/?onboarding_completed=true")
  }

  isStepOpened(stepNumber) {
    const step = this.getStepByNumber(stepNumber)

    return step.body.classList.value.includes("max-h-192")
  }

  setStepAsCompleted(stepNumber) {
    const step = this.getStepByNumber(stepNumber)

    step.container.dataset.step_completed = "true"
    this.toggleElementVisibility(step.number)
    this.toggleElementVisibility(step.checkmark)
    this.toggleElementVisibility(step.completeBtn)
    this.toggleStepHeaderState(step)
  }

  isAllStepsCompleted() {
    return this.isStepCompleted(this.step1) &&
           this.isStepCompleted(this.step2) &&
           this.isStepCompleted(this.step3)
  }

  isStepCompleted(step) {
    return step.container.dataset.step_completed == "true"
  }

  handleStepClick(event) {
    const currentStepNumber = this.stepNumberFrom(event.currentTarget)
    this.toggleStep(currentStepNumber)
  }

  getStepByNumber(stepNumber) {
    switch (stepNumber) {
      case 1:
        return this.step1
      case 2:
        return this.step2
      case 3:
        return this.step3
    }
  }

  toggleStep(stepNumber) {
    if (stepNumber > 3) return

    const step = this.getStepByNumber(stepNumber)
    this.toggleStepVisibility(step.body)
    this.toggleStepHighlight(step.container)
    this.toggleTogglerState(step.toggler)
  }

  toggleStepVisibility(stepBody){
    if (stepBody.classList.value.includes("max-h-0"))
      this.expandStep(stepBody)
    else
      this.collapseStep(stepBody)
  }

  toggleElementVisibility(element) {
    if (element.classList.value.includes("hidden"))
      element.classList.remove("hidden")
    else
      element.classList.add("hidden")
  }

  toggleStepHeaderState(step) {
    if (step.header.classList.value.includes("text-gray-500")) {
      step.header.classList.remove("text-gray-500", "font-normal")
      step.header.classList.add("font-medium")
    }
    else {
      step.header.classList.add("text-gray-500", "font-normal")
      step.header.classList.remove("font-medium")
    }
  }

  expandStep(stepBody) {
    stepBody.classList.remove("max-h-0")
    stepBody.classList.add("max-h-192")
  }

  collapseStep(stepBody) {
    stepBody.classList.remove("max-h-192")
    stepBody.classList.add("max-h-0")
  }

  toggleStepHighlight(stepContainer) {
    if (stepContainer.classList.value.includes("border border-z-blue"))
      this.unhighlightStep(stepContainer)
    else
      this.highlightStep(stepContainer)
  }

  highlightStep(stepContainer) {
    stepContainer.classList.add("border", "border-z-blue")
  }

  unhighlightStep(stepContainer){
    stepContainer.classList.remove("border", "border-z-blue")
  }

  toggleTogglerState(stepToggler){
    if (stepToggler.classList.value.includes("rotate-90"))
      stepToggler.classList.remove("rotate-90")
    else
      stepToggler.classList.add("rotate-90")
  }
}
