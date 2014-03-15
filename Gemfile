source 'https://rubygems.org'

gem 'rails', '3.2.15'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'mysql2'

gem 'devise'
gem 'devise-encryptable' # for authlogic encrypt algorithm
# gem "rails3_acts_as_paranoid", "~>0.2.0"
gem "rails3_acts_as_paranoid"
gem 'exception_notification', :require => 'exception_notifier'
gem "sanitize"
gem 'paperclip'
gem 'exifr'
gem "rails_autolink"
gem 'kaminari'
gem 'acts-as-taggable-on'
gem 'whenever', :require => false

# gem 'formtastic'
# gem 'formtastic-bootstrap'
gem 'simple_form'
gem 'twitter-bootstrap-rails'

gem 'rails_admin'
gem 'faker'

gem 'jpmobile'

# Uploadifyでflashによってセッションが切れてログアウトしてしまう問題の対応のため
# todo これだけじゃダメだった
# gem 'flash_cookie_session'
#

# 現在、ガラケーからのファイル添付のつぶやきにのみ使用
# ※tmailを有効にしたらログインフォームでエラーになった。全く不明
# gem 'tmail'
gem 'ruby-gmail', '0.3.0'

# なんかエラー出たから対処
gem 'less-rails', git: 'git://github.com/metaskills/less-rails.git'
gem 'therubyracer'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails', '2.1.3'
gem 'jquery-ui-rails', '2.0.2'

group :development do
  gem 'mongrel', '>= 1.2.0.pre2'

  gem 'rails-erd'
  gem 'rails-footnotes'
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'pry-doc'
  # PryでのSQLの結果を綺麗に表示
  gem 'hirb'
  gem 'hirb-unicode'
  gem 'awesome_print'
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
gem 'foreman'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'
