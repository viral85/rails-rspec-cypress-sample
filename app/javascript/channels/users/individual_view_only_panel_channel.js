import consumer from "../consumer"
import { getConsumerType } from "../consumer"
import CableReady from "cable_ready"

const consumerType = getConsumerType()

export function subscribeIndividualViewOnlyPanel(){
  if (consumerType == "InvitedUser") {
    consumer.subscriptions.create("IndividualViewOnlyPanelChannel", {
      connected() {},

      disconnected() {
        document.getElementById("sharingDisabledMessage").classList.remove("hidden")
        document.getElementById("sharedPanel").remove()
      },

      received(data) {
        if (data.cableReady) {
          CableReady.perform(data.operations, {
            emitMissingElementWarnings: false
          })
        }
      }
    })
  }
}
