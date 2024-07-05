# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

base_path = File.basename(__dir__) == "development_app" ? "../" : ""
require_relative "#{base_path}lib/decidim/homepage_interactive_map/version"

gem "decidim", Decidim::HomepageInteractiveMap::DECIDIM_VERSION
gem "decidim-homepage_interactive_map", path: "."

gem "bootsnap", "~> 1.4"
gem "puma", "~> 5.5.1"

gem "rgeo", "~> 3.0"
gem "rgeo-proj4", "~> 4.0"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  gem "decidim-dev", Decidim::HomepageInteractiveMap::DECIDIM_VERSION
end

group :development do
  gem "faker", "~> 2.14"
  gem "letter_opener_web", "~> 1.3"
  gem "listen", "~> 3.1"
  gem "rubocop-faker"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console", "~> 4.0.4"
end
