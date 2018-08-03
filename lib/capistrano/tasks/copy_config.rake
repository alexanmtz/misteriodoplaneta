namespace :deploy do

  desc 'Set the necessary file permissions'
  task :set_permissions do
    on roles(:app) do
      execute :chmod, "-R 2775 #{shared_path}/wordpress/wp-content/uploads"
    end
  end

  desc "copy local config to server after deploy"
  task :copy_config do
    on roles(:all) do
      puts "#### Start config generation ####"
      database = YAML.load_file('database.yml')
      puts database.inspect
      wpconfigFilePath = "config/deploy/templates/wp-config.php.erb"
      db_config = ERB.new(File.read(wpconfigFilePath)).result(binding)
      io = StringIO.new(db_config)
      upload! io, File.join(shared_path, 'wp-config.php')
      puts "#### End config generation ####"

      puts "#### start copy wp-config ####"
      execute "ln -nfs #{shared_path}/wp-config.php #{release_path}/wordpress/wp-config.php"
      puts "#### end copy wp-config"

      puts "#### link upload dir ####"
      execute "ln -nfs #{shared_path}/wordpress/wp-content/uploads #{release_path}/wordpress/wp-content/uploads"
    end
    invoke 'deploy:set_permissions'
  end
end

after 'deploy', 'deploy:copy_config'