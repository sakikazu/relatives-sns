source 'https://rubygems.org'

ruby '3.2.6'
gem 'rails', '~> 7.2'
gem 'bootsnap' # railsの起動を速くする

# Use mysql as the database for Active Record
gem 'mysql2'
# Use Puma as the app server
gem 'puma'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# for scss; NOTE: 2.4にすると、VPSでbundle installが終わらなくなる
gem 'sassc', '2.1.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
# gem 'coffee-rails', '~> 4.0.0'
gem 'bootstrap', '~> 4.3' # twitter bootstrap4

# Use jquery as the JavaScript library
gem 'jquery-rails'
# gem 'jquery-ui-rails', '2.0.2'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring',        group: :development

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# --- above defaults ---

# for heroku
gem 'rails_12factor', group: :production


gem 'devise'
gem 'devise-encryptable' # for authlogic encrypt algorithm
gem "paranoia", "~> 3.0"
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
gem 'redcarpet' # markdown

# ActiveStorage variants
gem 'image_processing', '~> 1.12'

# Ajaxでファイルアップロード
gem 'remotipart', '~> 1.2'

gem 'gcm'
gem 'apns'


# jquery-railsをバージョン指定するとこれがエラーになるぞ？？（2014/05/12）
# rails6にすると can't frozen AdminUser みたいなエラーが出るので、ひとまずコメントアウト
gem 'rails_admin'
gem 'faker'

gem 'browser'

# Uploadifyでflashによってセッションが切れてログアウトしてしまう問題の対応のため
# todo これだけじゃダメだった
# gem 'flash_cookie_session'
#

# 定数管理
gem 'config'

# NOTE: View handlerの設定で使用されるのでどの環境でも必要
gem 'slim'

group :development do
  gem 'rb-readline'
  gem 'listen'
  gem 'slim-rails'                # generator時にslim対応可能になる
  gem 'view_source_map'           # webページ中に使用されているviewファイル名が見れる
  gem 'annotate'
  gem 'bullet'                    # n+1検出
  gem 'rubocop', require: false
  # 邪魔なことが多いから無効に
  # gem 'rack-mini-profiler'        # 処理時間を表示

  # Use Capistrano for deployment
  gem 'capistrano', '~> 3.6'
  gem 'capistrano-bundler', '~> 2.0'
  gem 'capistrano-rails'
  gem 'capistrano3-unicorn'
  gem 'capistrano-sidekiq'
  gem 'capistrano3-nginx'
  gem 'capistrano3-puma'

  # エラー画面をわかりやすく整形してくれる
  gem 'better_errors'

  # better_errorsの画面上にirb/pry(PERL)を表示する
  gem 'binding_of_caller'

  # NOTE: deploy時の `fingerprint xxx does not match` エラー対策
  gem 'bcrypt_pbkdf'
  gem 'ed25519'
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
