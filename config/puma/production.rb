workers ENV.fetch("WEB_CONCURRENCY", 2)
threads_count = ENV.fetch("RAILS_MAX_THREADS", 5)
threads threads_count, threads_count

preload_app!

rackup DefaultRackup if defined?(DefaultRackup)
port ENV.fetch("PORT", 3000)
environment ENV.fetch("RAILS_ENV", "production")

on_worker_boot do
  ActiveRecord::Base.establish_connection
end

bind "unix:///home/ubuntu/web/adan/shared/tmp/sockets/puma.sock"
pidfile "/home/ubuntu/web/adan/shared/tmp/pids/puma.pid"
state_path "/home/ubuntu/web/adan/shared/tmp/pids/puma.state"
