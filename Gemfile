source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.0'
# Use mysql as the database for Active Record
gem 'mysql2'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
# gem 'coffee-rails', '~> 4.0.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring',        group: :development

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# --- above defaults ---


gem 'devise'
gem 'devise-encryptable' # for authlogic encrypt algorithm
gem "paranoia", "~> 2.0"
gem 'exception_notification'
gem "sanitize"
gem 'paperclip'
gem 'exifr'
gem "rails_autolink"
gem 'kaminari'
gem 'acts-as-taggable-on'
gem 'whenever', :require => false
gem 'dotenv-rails'

# gem 'formtastic'
# gem 'formtastic-bootstrap'
gem 'simple_form'
gem 'twitter-bootstrap-rails'
gem 'streamio-ffmpeg'
gem 'rmagick', require: 'RMagick'
gem 'sidekiq'

# Ajaxでファイルアップロード
gem 'remotipart', '~> 1.2'


# todo 問題なさげ？このまま大丈夫ならここ削除
# memo jquery 1.9以上になるとliveが使えずエラーになるのでバージョン指定
# gem 'jquery-rails', '2.1.3'
# gem 'jquery-ui-rails', '2.0.2'

# jquery-railsをバージョン指定するとこれがエラーになるぞ？？（2014/05/12）
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

gem 'less-rails'

# 定数管理
gem 'rails_config'


group :development, :test do
  # Railsコンソールの多機能版
  gem 'pry-rails'

  # pryの入力に色付け
  gem 'pry-coolline'

  # デバッカー
  gem 'pry-byebug'

  # Pryでの便利コマンド
  gem 'pry-doc'

  # PryでのSQLの結果を綺麗に表示
  gem 'hirb'
  gem 'hirb-unicode'

  # pryの色付けをしてくれる
  gem 'awesome_print'

  # テスト環境のテーブルをきれいにする
  gem 'database_rewinder'

  # デバッグ情報をフッターに出してくれる
  gem 'rails-footnotes', '>= 4.0.0', '<5'

  gem 'rails-erd'

  # for test
  gem 'rspec-rails'
  gem "factory_girl_rails"
  gem "rr"
  gem "capybara"
  gem 'spork'
  gem "guard-spork"
  gem "guard-rspec"

  # erbからhamlに変換
  gem 'erb2haml'

  # for deploy
  # Use Capistrano for deployment
  # gem 'capistrano'
  # gem 'capistrano-bundler'
  gem 'rvm1-capistrano3', require: false

end

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
gem 'unicorn'
gem 'foreman'

# Use Capistrano for deployment
gem 'capistrano-rails', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

