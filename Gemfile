source 'https://rubygems.org'

ruby '2.5.1'
gem 'rails', '~> 5.2.0'
gem 'bootsnap' # railsの起動を速くする

# Use mysql as the database for Active Record
gem 'mysql2'
# Use Puma as the app server
gem 'puma', '~> 3.7'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
# gem 'coffee-rails', '~> 4.0.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'mini_racer'
gem 'bootstrap', '~> 4.1.3' # twitter bootstrap4

# Use jquery as the JavaScript library
gem 'jquery-rails'
# gem 'jquery-ui-rails', '2.0.2'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring',        group: :development

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# --- above defaults ---

# for heroku
gem 'rails_12factor', group: :production


gem 'devise'
gem 'devise-encryptable' # for authlogic encrypt algorithm
gem "paranoia", "~> 2.0"
gem 'exception_notification'
gem "sanitize"
gem 'paperclip'
gem 'exifr'
gem "rails_autolink"
gem 'kaminari'
# gem 'acts-as-taggable-on'
gem 'whenever', :require => false
gem 'dotenv-rails'

gem 'simple_form'
gem 'streamio-ffmpeg'
gem 'rmagick'
gem 'sidekiq'
gem 'font-awesome-rails'

# Ajaxでファイルアップロード
gem 'remotipart', '~> 1.2'

gem 'gcm'
gem 'apns'


# jquery-railsをバージョン指定するとこれがエラーになるぞ？？（2014/05/12）
gem 'rails_admin'
gem 'faker'

gem 'jpmobile'

# Uploadifyでflashによってセッションが切れてログアウトしてしまう問題の対応のため
# todo これだけじゃダメだった
# gem 'flash_cookie_session'
#

# 定数管理
gem 'config'

# NOTE: View handlerの設定で使用されるのでどの環境でも必要
gem 'slim'

# for API
gem 'grape'
# gem 'rabl'
# gem 'oj'


group :development do
  gem 'listen'
  gem 'slim-rails'                # generator時にslim対応可能になる
  gem 'view_source_map'           # webページ中に使用されているviewファイル名が見れる
  gem 'annotate'
  gem 'bullet'                    # n+1検出
  gem 'rubocop', require: false
  # 邪魔なことが多いから無効に
  # gem 'rack-mini-profiler'        # 処理時間を表示

  # Use Capistrano for deployment
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano3-unicorn'
  gem 'capistrano-sidekiq'
  gem 'capistrano3-nginx'
  gem 'capistrano3-puma'
  gem 'rvm1-capistrano3', require: false

  # エラー画面をわかりやすく整形してくれる
  gem 'better_errors'

  # better_errorsの画面上にirb/pry(PERL)を表示する
  gem 'binding_of_caller'
end

group :development, :test do
  # rails consoleでpryを使うために必要
  gem 'pry-rails'

  # デバッガー
  gem 'pry-byebug'

  # Pryでの便利コマンド
  gem 'pry-doc'

  # PryでのSQLの結果を綺麗に表示
  gem 'hirb'

  # テスト環境のテーブルをきれいにする
  gem 'database_rewinder'

  gem 'rails-erd'

  # for test
  gem 'rspec-rails'
  gem "factory_bot"
  gem "capybara"
end

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
gem 'unicorn'
gem 'foreman'

