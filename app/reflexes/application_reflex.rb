# frozen_string_literal: true

class ApplicationReflex < StimulusReflex::Reflex
  delegate :client, to: :connection

  def current_user
    return client if connection.authorized_user?
    return connection.invitor_user if connection.valid_invited_user?
  end

  def current_participant
    client if connection.participant?
  end
end
