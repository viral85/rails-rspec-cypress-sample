// Load all the controllers within this directory and all subdirectories.
// Controller files must be named *_controller.js.
import { Application } from "stimulus"
import { definitionsFromContext } from "stimulus/webpack-helpers"
import StimulusReflex from "stimulus_reflex"

import consumer from "../channels/consumer"
import controller from "./application_controller"
import setupHoneyBadger from "./honeybadger_initializer"

const env = document.querySelector("meta[name='env']").content
const application = Application.start()
const context = require.context("controllers", true, /_controller\.js$/)

application.load(definitionsFromContext(context))
StimulusReflex.initialize(application, { consumer, controller, debug: (env !== "production") })
setupHoneyBadger(application, env)

import { Dropdown, Modal } from "tailwindcss-stimulus-components"
application.register("dropdown", Dropdown)
application.register("modal", Modal)



if (env === "development") {
  import("radiolabel").then(Radiolabel =>
    application.register("radiolabel", Radiolabel.default)
  )
}
