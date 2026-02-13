# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "colorize"
gem "optparse"
gem "thor"
gem "irb"
gem "rake", "~> 13.0"

group :development, :test do
  gem "aruba"
  gem "pry"
  gem "pry-byebug"
  gem "rspec"
  gem "simplecov"
end

group :development do
  gem "brakeman"
  gem "rubocop-rspec"
  gem "rubocop-thread_safety"
  gem "rubocop-rails-omakase", require: false
  gem "ruby_audit"
  gem "standard"
end
