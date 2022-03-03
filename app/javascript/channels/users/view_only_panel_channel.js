import consumer from "../consumer"
import { getConsumerType } from "../consumer"
import CableReady from "cable_ready"

const consumerType = getConsumerType()

export function subscribeViewOnlyPanel(){
  if (consumerType == "InvitedUser") {
    consumer.subscriptions.create("ViewOnlyPanelChannel", {
      connected() {},

      disconnected() {},

      received(data) {
        if (data.signal == "redirect_to_no_access_page") {
          Turbolinks.visit("/no_access")
        } else if (data.cableReady) {
          CableReady.perform(data.operations, {
            emitMissingElementWarnings: false
          })
        }
      }
    })
  }
}
