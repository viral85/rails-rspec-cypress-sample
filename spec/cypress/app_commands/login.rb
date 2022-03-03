module TestHelpers
  class LoginAs
    include Warden::Test::Helpers

    def self.run(username)
      new.run(username)
    end

    def run(email = nil)
      user = if email.present?
               User.find_by(email: email)
             else
               User.last
             end
      login_as(user, scope: :user)
    end
  end
end

TestHelpers::LoginAs.run(command_options)
