# Load DSL and Setup Up Stages
require 'capistrano/setup'

# Includes default deployment tasks
require 'capistrano/deploy'

require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

# Includes tasks from other gems included in your Gemfile
#
# For documentation on these, see for example:
#
#   https://github.com/capistrano/rbenv
#   https://github.com/capistrano/chruby
#   https://github.com/capistrano/bundler
#   https://github.com/capistrano/rails
#
# require 'capistrano/rbenv'
# require 'capistrano/chruby'
require 'capistrano/bundler'
require 'capistrano/rails/assets'
require 'capistrano/rails/migrations'
require 'capistrano3/unicorn'

# sidekiq起動
# NOTE: https://zenn.dev/ryouzi/articles/d340173eb0386d を参考に sidekiq.serviceを作る必要があったが、
# capistrano実行時はそれがNot foundになるので結局、手動で `sudo systemctl start sidekiq` をしている
# require 'capistrano/sidekiq'
# install_plugin Capistrano::Sidekiq  # Default sidekiq tasks
# # Then select your service manager
# install_plugin Capistrano::Sidekiq::Systemd

# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
