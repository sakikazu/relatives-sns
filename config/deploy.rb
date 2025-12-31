# config valid only for Capistrano 3.2.1
lock '3.19.2'

require 'dotenv/load'
Dotenv.load

set :application, 'adan'
set :repo_url, ENV['BITBUCKET_URL']

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/home/ubuntu/web/adan'

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{.env}

# memo jsライブラリで使用するcssやfontなど、assetUrl関連で問題となりそうなものは、コンパイルせずに直接参照できるように、shared配下に配置する
# Default value for linked_dirs is []
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets bundle public/upload storage}
append :linked_dirs, '.bundle'

# Default value for default_env is {}
set :default_env, {
  # NOTE: asdf global 設定にしたrubyを使わない場合は、これだとダメかも
  path: "/home/ubuntu/.asdf/shims:/home/ubuntu/.asdf/bin:$PATH",
  "ASDF_DIR" => "/home/ubuntu/.asdf"
}

# Default value for keep_releases is 5
# set :keep_releases, 5


namespace :deploy do
  desc 'Restart application'
  task :restart do
    invoke "puma:restart"
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

namespace :deploy do
  task :set_ruby_version do
    on roles(:app) do
      within release_path do
        execute :asdf, "install"
      end
    end
  end
end

before "deploy:updated", "deploy:set_ruby_version"

### sidekiq起動
# NOTE: sidekiq起動ユーザーはデプロイユーザーと同じにしておかないと、エンコードされた動画がrootになって削除不可になってしまう
#       /lib/systemd/system/sidekiq.serviceファイルにてユーザーを指定している
#       また、sudoのパスワード入力を回避するため、visudoでNOPASSWD設定を行っている
namespace :sidekiq do
  desc 'Restart Sidekiq'
  task :restart do
    on roles(:app) do
      execute :sudo, "systemctl restart sidekiq"
    end
  end
end
