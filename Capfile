# Load DSL and Setup Up Stages
require 'capistrano/setup'

# Includes default deployment tasks
require 'capistrano/deploy'

require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

require 'capistrano/bundler'
require 'capistrano/rails'
require 'capistrano/asdf'
require 'capistrano/puma'
install_plugin Capistrano::Puma
install_plugin Capistrano::Puma::Systemd

# sidekiq起動
# NOTE: https://zenn.dev/ryouzi/articles/d340173eb0386d を参考に sidekiq.serviceを作る必要があったが、
# capistrano実行時はそれがNot foundになるので、cap production sidekiq:restartで再起動している
# require 'capistrano/sidekiq'
# install_plugin Capistrano::Sidekiq  # Default sidekiq tasks
# # Then select your service manager
# install_plugin Capistrano::Sidekiq::Systemd

# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
