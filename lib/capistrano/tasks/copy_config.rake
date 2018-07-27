namespace :deploy do
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

      puts "#### start copy wp-config"
      execute "ln -nfs #{shared_path}/wp-config.php #{release_path}/wordpress/wp-config.php"
      puts "#### end copy wp-config"
    end
  end
end

after 'deploy', 'deploy:copy_config'