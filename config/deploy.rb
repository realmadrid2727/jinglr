require 'rvm/capistrano'
require 'bundler/capistrano'
require 'delayed/recipes'
#require 'capistrano/ext/multistage'

set :application, "Jinglr"
set :repository,  "https://realmadrid2727@bitbucket.org/realmadrid2727/jinglr.git"
set :deploy_to, "/var/www/apps/jinglr"
set :scm, :git
set :branch, "master"
set :user, "root"
set :rails_env, "production"
set :deploy_via, :copy
set :keep_releases, 5

# Set the public folder in the shared capistrano folder
set :shared_assets, %w{public/assets}

set :delayed_job_command, "bin/delayed_job"

set :rvm_ruby_string, :local

set :rvm_autolibs_flag, :enable
#set :use_sudo, true

before 'deploy:setup', 'rvm:install_rvm'   # install RVM
before 'deploy:setup', 'rvm:install_ruby'  # install Ruby and create gemset

after "deploy:stop",    "delayed_job:stop"
after "deploy:start",   "delayed_job:start"
after "deploy:restart", "delayed_job:restart"

#role :web, "nginx"                          # Your HTTP server, Apache/etc
#role :app, "passenger"                          # This may be the same as your `Web` server
#role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

default_run_options[:pty] = true

server "208.66.193.10", :app, :web, :db, :primary => true

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

namespace :deploy do
  namespace :assets do
    task :precompile, :roles => assets_role, :except => { :no_release => true } do
      run <<-CMD.compact
        cd -- #{latest_release.shellescape} &&
        #{rake} RAILS_ENV=#{rails_env.to_s.shellescape} #{asset_env} assets:precompile
      CMD
    end
  end
end

namespace :assets  do
  namespace :symlinks do
    desc "Setup application symlinks for shared assets"
    task :setup, :roles => [:app, :web] do
      shared_assets.each { |link| run "mkdir -p #{shared_path}/#{link}" }
    end

    desc "Link assets for current deploy to the shared location"
    task :update, :roles => [:app, :web] do
      shared_assets.each { |link| run "ln -nfs #{shared_path}/#{link} #{release_path}/#{link}" }
    end
  end
end

before "deploy:setup" do
  assets.symlinks.setup
end

before "deploy:symlink" do
  assets.symlinks.update
end