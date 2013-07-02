namespace_with_fontana :sync, :"runtime:update" do
  desc "sync app/scripts directly"
  fontana_task :app_scripts, before: ->{ ENV["APP_SCRIPTS_PATH"] = File.expand_path("../app/scripts", __FILE__) }

  desc "sync spec/fixtures directly"
  fontana_task :spec_fixtures, before: ->{ ENV["SPEC_FIXTURES_PATH"] = File.expand_path("../spec/fixtures", __FILE__) }

  desc "sync app/scripts and spec/fixtures directly"
  fontana_task :client, before: ->{
    ENV["APP_SCRIPTS_PATH"] = File.expand_path("../app/scripts", __FILE__)
    ENV["SPEC_FIXTURES_PATH"] = File.expand_path("../spec/fixtures", __FILE__)
  }
end
