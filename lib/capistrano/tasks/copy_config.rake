namespace :deploy do

  task :copy_config do
    on release_roles :app do |role|
      fetch(:linked_files).each do |linked_file|
        user = fetch(:user)
        hostname = role.hostname
        linked_files(shared_path).each do |file|
          next unless file.to_s =~ /config/
          run_locally do
            execute :rsync, "config/#{file.to_s.gsub(/.*\/(.*)$/,"\\1")}", "#{user}#{hostname}:#{file.to_s.gsub(/(.*)\/[^\/]*$/, "\\1")}/"
          end
        end
      end
    end
  end

end

before "deploy:check:linked_files", "deploy:copy_config"
