module Participants
  class ParticipantsController < ApplicationController
    before_action :set_participant_page

    private

    def set_participant_page
      @participant_page = true
    end
  end
end
