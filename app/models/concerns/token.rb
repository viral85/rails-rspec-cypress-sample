module Token
  extend ActiveSupport::Concern

  def generate_friendly_token
    return if token.present?

    length = 6
    token = loop do
      random_token = SecureRandom.alphanumeric(length).upcase
      break random_token unless self.class.where(token: random_token).exists?
    end
    self.token = token
  end
end
