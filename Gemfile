source 'https://rubygems.org'

gem 'rails', '3.2.8'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'mysql2'

gem 'devise'
# gem "rails3_acts_as_paranoid", "~>0.2.0"
gem "rails3_acts_as_paranoid"
gem 'exception_notification', :require => 'exception_notifier'
gem "sanitize"
gem 'paperclip'
gem 'exifr'
gem "rails_autolink"
gem 'kaminari'
gem 'acts-as-taggable-on'

# gem 'formtastic'
# gem 'formtastic-bootstrap'
gem 'simple_form'
gem 'twitter-bootstrap-rails'

gem 'typus'
gem 'faker'

gem 'jpmobile'

# Uploadifyでflashによってセッションが切れてログアウトしてしまう問題の対応のため
# todo これだけじゃダメだった
# gem 'flash_cookie_session'
#
# gem 'tmail'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

group :development do
  gem 'mongrel', '>= 1.2.0.pre2'

  gem 'ruby-debug19'
  gem 'rails-erd'
  gem 'rails-footnotes'
  gem 'pry-rails'
end

group :development, :test do
  gem "rspec"
  gem "rspec-rails"
  # gem "factory_girl_rails" // 2012-08-25現在、r g scaffoldにてエラーになる
  gem "rails3-generators"
  gem "rr"
  gem "capybara"
  gem 'spork'
  gem "guard-spork"
  gem "guard-rspec"

  # gem "hocus_pocus"
end



# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'
