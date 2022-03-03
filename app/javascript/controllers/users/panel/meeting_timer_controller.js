import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "timer" ]
  static values = {
    startedAt: String
  }
  interval

  connect() {
    const startedAt = this.startedAtValue
    const countFrom = new Date(startedAt).getTime()
    const now = new Date()
    const timeDifference = Math.round( (now - countFrom) / 1000  )

    this.setMeetingTimer(timeDifference)
  }

  disconnect(){
    clearInterval(this.interval)
  }

  setMeetingTimer(difference){
    let totalSeconds = difference
    const target = this.timerTarget
    this.interval = setInterval(function(){
      ++totalSeconds
      let hour = Math.floor(totalSeconds / 3600)
      let minute = Math.floor((totalSeconds - hour * 3600) / 60)
      let seconds = totalSeconds - (hour * 3600 + minute * 60)
      if(hour < 10)
        hour = "0" + hour
      if(minute < 10)
        minute = "0" + minute
      if(seconds < 10)
        seconds = "0" + seconds
      target.innerHTML = hour + ":" + minute + ":" + seconds
    }, 1000)
  }
}
