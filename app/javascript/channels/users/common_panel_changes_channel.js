import consumer from "../consumer"
import { getConsumerType } from "../consumer"
import CableReady from "cable_ready"

const consumerType = getConsumerType()

export function subscribeCommonPanelChanges(){
  if (consumerType == "User" || consumerType == "InvitedUser") {
    consumer.subscriptions.create("CommonPanelChangesChannel", {
      connected() {},

      disconnected() {},

      received(data) {
        if (data.webhook_signal) {
          document.dispatchEvent(new CustomEvent("webhook-signal",
            {
              detail: data.webhook_signal
            }
          ))
        } else if (data.cableReady) {
          CableReady.perform(data.operations, {
            emitMissingElementWarnings: false
          })
        }
      }
    })

    consumer.connection.events.error = function(e) {
      document.dispatchEvent(new CustomEvent("websocket-connection-lost"))
    }
  }
}
