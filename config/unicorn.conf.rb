working_directory '/usr/local/site/adan/current'
listen '/tmp/unicorn_adan.sock', :backlog => 1024
# listen "127.0.0.1:8080"
pid 'tmp/pids/unicorn.adan.pid'

# worker_processes 2

# ダウンタイムなくす
preload_app true

stderr_path File.expand_path('log/unicorn.log', ENV['RAILS_ROOT'])
stdout_path File.expand_path('log/unicorn.log', ENV['RAILS_ROOT'])

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!

  old_pid = "#{ server.config[:pid] }.oldbin"
  unless old_pid == server.pid
    begin
      # SIGTTOU た?と worker_processes か?多いときおかしい気か?する
      Process.kill :QUIT, File.read(old_pid).to_i
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
end



