namespace_with_fontana :fixtures, :"app:fixtures" do

  desc "load collection fixture"
  fontana_task :load, before: ->{
    raise "$FIXTURE is required" unless ENV['FIXTURE']
    ENV['FIXTURE'] = File.expand_path(ENV['FIXTURE'], '.')
  }

  desc "dump collection fixture to path"
  fontana_task :dump, before: ->{
    raise "$COLLECTION is required" unless ENV['COLLECTION'] || ENV['COL']
    raise "$FIXTURES_DIR is required" unless ENV['FIXTURES_DIR']
    ENV['FIXTURES_DIR'] = File.expand_path(ENV['FIXTURES_DIR'], '.')
  }

  namespace_with_fontana :dump do
    desc "dump all collections"
    fontana_task :all, before: ->{
      raise "$FIXTURES_DIR is required" unless ENV['FIXTURES_DIR']
      ENV['FIXTURES_DIR'] = File.expand_path(ENV['FIXTURES_DIR'], '.')
    }
  end

end
