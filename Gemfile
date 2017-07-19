source 'https://rubygems.org'

gem "rails", "~> 2.3.18"
gem "ruby-ldap"
gem "activeldap", :require => "active_ldap"
gem "icu4r_19", :git => 'https://github.com/pedz/icu4r_19.git'
gem "beanstalk-client"
gem "pg"
gem "thin"
gem 'capistrano', '~> 3.0', require: false, group: :development

group :development do
  gem 'capistrano-rails',   '~> 1.1', require: false
  gem 'capistrano-bundler', '~> 1.1', require: false
  gem('rails-footnotes',
      '3.6.7',
      :git => 'http://github.com/jasoncodes/rails-footnotes.git',
      :branch => 'rails2')
  gem "jasmine"
  gem 'spreadsheet', '0.6.5.9'
end
