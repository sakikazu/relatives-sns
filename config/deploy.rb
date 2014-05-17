# config valid only for Capistrano 3.2.1
lock '3.2.1'

set :application, 'adan'
set :repo_url, 'git@bitbucket.org:sakikazu15/adan.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# for sidekiq that perform a proccess asyncronously
# todo 動いてない。（2014/05/17）
require 'sidekiq/capistrano'
set :sidekiq_role, :web

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/usr/local/site/adan'

# Default value for :scm is :git
set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{.env config/mysqldump.ini .ruby-version .ruby-gemset}

# Default value for linked_dirs is []
set :linked_dirs, %w{log tmp/cache tmp/sockets vendor/bundle public/upload public/assets/font}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # for unicorn
      execute :cat, "/tmp/unicorn.adan.pid | xargs kill -USR2"
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
