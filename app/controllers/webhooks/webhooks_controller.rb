module Webhooks
  class WebhooksController < ApplicationController
    skip_before_action :verify_authenticity_token
  end
end
