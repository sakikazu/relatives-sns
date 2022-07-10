# config valid only for Capistrano 3.2.1
lock '3.17.0'

require 'dotenv/load'
Dotenv.load

set :application, 'adan'
set :repo_url, ENV['BITBUCKET_URL']

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/usr/local/site/adan'

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{.env config/mysqldump.ini .ruby-version .ruby-gemset}

# memo jsライブラリで使用するcssやfontなど、assetUrl関連で問題となりそうなものは、コンパイルせずに直接参照できるように、shared配下に配置する
# Default value for linked_dirs is []
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/upload}
append :linked_dirs, '.bundle'

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :rvm1_type, :system
set :rvm1_ruby_version, '2.7.1'

# unicorn
set :unicorn_config_path, "#{current_path}/config/unicorn.conf.rb"
# set :unicorn_pid, 'default'

# sidekiq
set :sidekiq_config, 'config/sidekiq.yml'
set :sidekiq_role, :web
SSHKit.config.command_map[:sidekiq] = "bundle exec sidekiq"
SSHKit.config.command_map[:sidekiqctl] = "bundle exec sidekiqctl"


namespace :deploy do

  desc 'Restart application'
  task :restart do
    invoke 'unicorn:restart'
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
