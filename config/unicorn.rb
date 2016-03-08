root = "/home/deployer/apps/expresso/current"
working_directory root
pid "#{root}/tmp/pids/unicorn.pid"
stderr_path "#{root}/log/unicorn.log"
stdout_path "#{root}/log/unicorn.log"

listen "/tmp/unicorn.expresso.sock"
worker_processes 25
timeout 120
