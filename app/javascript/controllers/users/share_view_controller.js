import { Controller } from "stimulus"

import { subscribeShareViewChannel } from "../../channels/users/share_view_channel"
export default class extends Controller {
  connect() {
    subscribeShareViewChannel()
  }
}
