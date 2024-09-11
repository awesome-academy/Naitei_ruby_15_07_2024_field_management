source "https://rubygems.org"
git_source(:github){|repo| "https://github.com/#{repo}.git"}

ruby "3.2.2"

gem "active_model_serializers"
gem "active_storage_validations", "0.9.8"
gem "bcrypt", "3.1.18"
gem "bootsnap", require: false
gem "bootstrap", "~> 5.2.0"
gem "cancancan"
gem "caxlsx"
gem "caxlsx_rails"
gem "chartkick"
gem "config"
gem "devise"
gem "faker", "2.21.0"
gem "figaro"
gem "font-awesome-sass"
gem "groupdate"
gem "i18n"
gem "image_processing", "1.12.2"
gem "importmap-rails"
gem "jbuilder"
gem "jwt"
gem "mysql2", "~> 0.5"
gem "omniauth-google-oauth2"
gem "omniauth-rails_csrf_protection"
gem "pagy"
gem "public_activity"
gem "puma", "~> 5.0"
gem "rails", "~> 7.0.5"
gem "ransack"
gem "sassc-rails"
gem "sidekiq"
gem "sidekiq-status"
gem "sprockets-rails"
gem "stimulus-rails"
gem "turbo-rails"
gem "tzinfo-data", platforms: %i(mingw mswin x64_mingw jruby)

group :development, :test do
  gem "debug", platforms: %i(mri mingw x64_mingw)
  gem "factory_bot_rails"
  gem "rails-controller-testing"
  gem "rspec-rails", "~> 5.0.0"
  gem "rubocop", "~> 1.26", require: false
  gem "rubocop-checkstyle_formatter", require: false
  gem "rubocop-rails", "~> 2.14.0", require: false
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "rails-controller-testing" # rubocop:disable Bundler/DuplicatedGem
  gem "selenium-webdriver"
  gem "shoulda-matchers"
  gem "webdrivers"
end
