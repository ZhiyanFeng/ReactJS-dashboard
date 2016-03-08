require "bundler/capistrano"

#server "192.155.94.183", :web, :app, :db, primary: true
#server "66.228.58.218", :web, :app, :db, primary: true
#server "54.85.120.94", :web, :app, :db, primary: true

desc "Run tasks in testing environment."
task :testing do
  server "52.53.212.187", :web, :app, :db, primary: true
  set :scm, "git"
  set :repository, "git@github.com:dc85/#{application}.git"
  set :branch, "test"
  set :rake, "#{rake} --trace"
end

desc "Run tasks in staging environment."
task :staging do
  server "192.155.94.183", :web, :app, :db, primary: true
  set :scm, "git"
  set :repository, "git@github.com:dc85/#{application}.git"
  set :branch, "staging"
end

desc "Run tasks in production environment."
task :production do
  server "66.228.58.218", :web, :app, :db, primary: true
  set :scm, "git"
  set :repository, "git@github.com:dc85/#{application}.git"
  set :branch, "master"
end

set :application, "expresso"
set :user, "deployer"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false
set :keep_releases, 3

#set :scm, "git"
#set :repository, "git@github.com:dc85/#{application}.git"
#set :branch, "master"


#default_run_options[:pty] = true
ssh_options[:forward_agent] = true
ssh_options[:keys] = "~/.ssh/staging-server.pem"

after "deploy", "deploy:cleanup" # keep only the last 5 releases

namespace :deploy do
  %w[start stop restart].each do |command|
    desc "#{command} unicorn server"
    task command, roles: :app, except: {no_release: true} do
      run "/etc/init.d/unicorn_#{application} #{command}"
    end
  end

  desc 'Load DB schema - CAUTION: rewrites database!'
  task :load_schema, :roles => :app do
    run "cd #{current_path}; bundle exec rake db:schema:load RAILS_ENV=#{rails_env}"
  end

  task :setup_config, roles: :app do
    sudo "ln -nfs #{current_path}/config/nginx.conf /etc/nginx/sites-enabled/#{application}"
    sudo "ln -nfs #{current_path}/config/unicorn_init.sh /etc/init.d/unicorn_#{application}"
    run "mkdir -p #{shared_path}/config"
    put File.read("config/database.example.yml"), "#{shared_path}/config/database.yml"
    put File.read("config/environment.rb"), "#{shared_path}/config/environment.rb"
    put File.read("config/unicorn.rb"), "#{shared_path}/config/unicorn.rb"
    put File.read("config/newrelic.yml"), "#{shared_path}/config/newrelic.yml"
    put File.read("config.ru"), "#{shared_path}/config.ru"
    puts "Now edit the config files in #{shared_path}."
  end
  after "deploy:setup", "deploy:setup_config"

  task :symlink_config, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/environment.rb #{release_path}/config/environment.rb"
    run "ln -nfs #{shared_path}/config/unicorn.rb #{release_path}/config/unicorn.rb"
    run "ln -nfs #{shared_path}/config.ru #{release_path}/config.ru"
  end
  after "deploy:finalize_update", "deploy:symlink_config"

  desc "Make sure local git is in sync with remote."
  task :check_revision, roles: :web do
    #unless `git rev-parse HEAD` == `git rev-parse origin/master`
    #  puts "WARNING: HEAD is not the same as origin/master"
    #  puts "Run `git push` to sync changes."
    #  exit
    #end
  end

  before "deploy", "deploy:check_revision"
end
