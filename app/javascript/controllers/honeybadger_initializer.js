import * as Honeybadger from "@honeybadger-io/js"

export default function setupHoneyBadger(application, env) {
  const hb_api_key =
    document.querySelector("meta[name='honeybadger-js-api-key']").content

  const shouldReportErrors = (env == "staging" || env == "production")

  if (shouldReportErrors) {
    Honeybadger.configure({
      apiKey: hb_api_key,
      environment: env
    })

    application.handleError = (error, message, detail) => {
      Honeybadger.notify(error)
    }

    document.addEventListener("zoom-error", (e) => {
      Honeybadger.setContext({
        meetingNumber: e.detail.meetingNumber,
        errorDetails: e.detail.error
      })
      Honeybadger.notify(e.detail.error.errorMessage)
    })
  }
}
