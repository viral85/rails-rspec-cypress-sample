import consumer from "../consumer"
import { getConsumerType } from "../consumer"
import CableReady from "cable_ready"

const consumerType = getConsumerType()

export function subscribeHostPanel(){
  if (consumerType == "User") {
    consumer.subscriptions.create("HostPanelChannel", {
      connected() {},

      disconnected() {},

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
