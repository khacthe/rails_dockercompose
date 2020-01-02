# Ask for the Rails root path. (When placed in RAILS_ROOT / config / unicorn.rb.)
rails_root = File.expand_path('../../', __FILE__)
# Find RAILS_ENV. (Used when you want to change the behavior for each RAILS_ENV. Not used this time.)
# rails_env = ENV['RAILS_ENV'] || "development"

# It is described in the postscript. You should put it.
ENV['BUNDLE_GEMFILE'] = rails_root + "/Gemfile"

# Unicorn starts with multiple workers, so define the number of workers
# It can be changed by server memory.
worker_processes 4

# No need to specify.
# Specify the directory to execute the Unicorn startup command.
# (If you do, you won't be able to hit this file in another directory.)
working_directory rails_root

# Connection timeout time
timeout 60

# Specify the location of Unicorn error log and normal log.
stderr_path File.expand_path('../../log/unicorn_stderr.log', __FILE__)
stdout_path File.expand_path('../../log/unicorn_stdout.log', __FILE__)

# Perform the following settings when using with Nginx.
# listen File.expand_path('../../tmp/sockets/unicorn.sock', __FILE__)
# If you want to start up and check the operation, make the following settings.
#listen 8080
listen 3000
# * There are "backlog" and "tcp_nopush" settings, but I don't understand.

# Specify the save destination of the PID file necessary for stopping the process.
pid File.expand_path('../../tmp/pids/unicorn.pid', __FILE__)

# Basically, specify `true`. Unicorn restarts with no downtime.
preload_app true
# Commented out because I saw the article with no effect.
# GC.respond_to?(:copy_on_write_friendly=) and GC.copy_on_write_friendly = true

# Stop old process upon receiving USR2 signal.
# As described later, there is a good thing when linking with Nginx.
before_fork do |server, worker|
  defined?(ActiveRecord::Base) and
      ActiveRecord::Base.connection.disconnect!

  old_pid = "#{server.config[:pid]}.oldbin"
  if old_pid != server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
end
