require "sidekiq/testing"
# Sidekiq::Testing.fake! # fake is the default mode
Sidekiq::Testing.inline!
# Sidekiq::Testing.disable!
