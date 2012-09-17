listen '/tmp/unicorn.sock', :backlog => 1024
#listen "127.0.0.1:8080"
pid '/tmp/unicorn.pid'

#stderr_path File.expand_path('log/unicorn.log', ENV['RAILS_ROOT'])
#stdout_path File.expand_path('log/unicorn.log', ENV['RAILS_ROOT'])
