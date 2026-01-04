source "https://rubygems.org"

gem "rails", "~> 8.1.0.beta1"
gem "propshaft"
gem "sqlite3", ">= 2.1"
gem "puma", ">= 5.0"
gem "jbuilder"

gem "importmap-rails"
gem "stimulus-rails"
gem "turbo-rails"
gem "tailwindcss-rails"

# gem "bcrypt", "~> 3.1.7"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

gem "bootsnap", require: false
gem "kamal", require: false
gem "thruster", require: false


group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "bundler-audit", require: false
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "web-console"
  gem "letter_opener"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end

gem "pagy", "~> 6.0"
gem "geared_pagination", "~> 1.2"
gem "rqrcode"
gem "image_processing", "~> 1.2"
