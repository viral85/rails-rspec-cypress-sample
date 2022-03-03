import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "timer" ]
  static values = {
    enteredAt: String
  }

  connect() {
    const enteredAt = this.enteredAtValue
    const countFrom = new Date(enteredAt).getTime()
    const now = new Date()
    const timeDifference = Math.round( (now - countFrom) / 1000  )

    this.startTimer(timeDifference)
  }

  startTimer(difference){
    let minutes = Math.floor(difference / 60)
    const target = this.timerTarget
    target.innerHTML = `${minutes} min`


    setInterval(function() {
      minutes += 1
      target.innerHTML = `${minutes} min`
    }, 60000)
  }
}
