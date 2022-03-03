require "simplecov"
if ENV["COVERAGE"]
  SimpleCov.start "rails" do
    coverage_dir("public/coverage/rspec")
    add_group "Services", "app/services"
    add_group "Reflexes", "app/reflexes"
  end
end
require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require "factory_bot"
require File.expand_path("../config/environment", __dir__)
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"
require "webmock/rspec"
require "sidekiq/testing"
Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }
Dir[Rails.root.join("spec/stub_requests/**/*.rb")].sort.each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  OmniAuth.config.test_mode = true
  config.include OmniauthMacros, type: :request
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include WardenHelper, type: :request
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  Shoulda::Matchers.configure do |sm_config|
    sm_config.integrate do |with|
      with.test_framework :rspec
      with.library :rails
    end
  end

  WebMock.allow_net_connect!(net_http_connect_on_start: true)
end
