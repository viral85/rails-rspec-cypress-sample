module TestHelpers
  require "webmock"
  include WebMock::API

  class EnableWebmock
    def self.run
      new.run
    end

    def run
      WebMock.enable!
      WebMock.reset!
    end
  end
end

TestHelpers::EnableWebmock.run
