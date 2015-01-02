# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'blog'
set :repo_url, 'git@github.com:the-swap/blog.git'
set :deploy_to, '/nfs/apps/blog_production'

set :ssh_options, {
  forward_agent: true
}

set :pty, true
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle
  public/system}

# Default value for default_env is {}
set :default_env, { path: "/opt/rbenv/shims:$PATH" }

stage = "production"
shared_path = "/nfs/apps/blog_production/shared"
puma_sock    = "unix://#{shared_path}/sockets/puma.sock"
puma_control = "unix://#{shared_path}/sockets/pumactl.sock"
puma_state   = "#{shared_path}/sockets/puma.state"
puma_log     = "#{shared_path}/log/puma-#{stage}.log"

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
      execute 'sudo /etc/init.d/puma restart'
    end
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
