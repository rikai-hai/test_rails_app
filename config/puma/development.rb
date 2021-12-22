require 'puma/daemon'

workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['RAILS_MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!
bind  "unix:///var/tmp/test_rails_app.sock"
pidfile "/var/run/puma/test_rails_app.pid"
stdout_redirect "/deploy/apps/test_rails_app/repo/test_rails_app/log/test_rails_app.log"
rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  # Valid on Rails up to 4.1 the initializer method of setting `pool` size
  ActiveSupport.on_load(:active_record) do
    config = ActiveRecord::Base.configurations[Rails.env] ||
                Rails.application.config.database_configuration[Rails.env]
    ActiveRecord::Base.establish_connection(config)
  end
end
