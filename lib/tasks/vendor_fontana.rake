namespace :vendor do
  namespace :fontana do

    desc "clear"
    task :clear do
      FileUtils.rm_rf(FontanaClientSupport.vendor_fontana)
    end

    desc "clone"
    task :clone => :"vendor:fontana:clear" do
      raise "$FONTANA_REPO_URL is required" unless Fontana.repo_url
      FileUtils.mkdir_p(FontanaClientSupport.vendor_dir)
      Dir.chdir(FontanaClientSupport.vendor_dir) do
        system!("git clone #{Fontana.repo_url}")
      end
      Dir.chdir(FontanaClientSupport.vendor_fontana) do
        system!("git checkout #{Fontana.branch}")
        FileUtils.cp(File.join(FontanaClientSupport.root_dir, "spec/server_config/mongoid.yml"), "config/mongoid.yml")
        FileUtils.cp("config/project.yml.erb.example", "config/project.yml.erb")
        system!("BUNDLE_GEMFILE=#{Fontana.gemfile} bundle install")
      end
      Rake::Task["deploy:reset"].execute
    end

    desc "update"
    task :update do
      Dir.chdir(FontanaClientSupport.vendor_fontana) do
        system!("git fetch origin")
        system!("git checkout origin/#{Fontana.branch}")
        system!("BUNDLE_GEMFILE=#{Fontana.gemfile} bundle install")
        system!("BUNDLE_GEMFILE=#{Fontana.gemfile} bundle exec rake db:drop")
      end
      Rake::Task["deploy:update"].execute
    end

    desc "prepare"
    task :prepare do
      if Dir.exist?(FontanaClientSupport.vendor_fontana)
        Rake::Task["vendor:fontana:update"].execute
      else
        Rake::Task["vendor:fontana:clone"].execute
      end
    end
  end

  desc "prepare vendor/fontana "
  task :fontana => :"vendor:fontana:prepare"
end
