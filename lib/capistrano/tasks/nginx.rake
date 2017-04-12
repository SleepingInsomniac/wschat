namespace :nginx do
  task :link do
    on roles(:app) do |host|
      path = File.join(fetch(:nginx_sites_path, '/etc/nginx/sites-enabled'), "#{fetch(:application)}.conf")
      execute "ln -f -s #{release_path}/config/nginx.conf #{path}"
    end
  end
end

after 'deploy:updated', 'nginx:link'
