# -*- coding: utf-8 -*-
require "rspec/core/rake_task"

require 'fileutils'

RSpec::Core::RakeTask.new(:spec)

root_dir = File.expand_path("..", __FILE__)
vendor_dir = File.expand_path("../vendor", __FILE__)
vendor_fontana = File.expand_path("../vendor/fontana", __FILE__)

fontana_repo_url = ENV['FONTANA_REPO_URL']
fontana_branch   = ENV['FONTANA_BRANCH'] || 'master'

FONTANA_HOME = ENV['FONTANA_HOME'] || (Dir.exist?(vendor_fontana) or fontana_repo_url) ? vendor_fontana : File.expand_path("../../fontana", __FILE__)
FONTANA_ENV  = ENV['FONTANA_ENV'] || "LibgssTest"

ENV['DEFAULT_HTTP_PORT'] ||= '3000'
ENV['DEFAULT_HTTPS_PORT'] ||= '3001'

TASK_OPTIONS = {}

def system!(cmd)
  puts "now executing: #{cmd}"

  IO.popen("#{cmd} 2>&1") do |io|
    while line = io.gets
      puts line
    end
  end

  if $?.exitstatus != 0
    exit(1)
  end
end

def call_fontana_task(name)
  options = TASK_OPTIONS[name]
  options[:before].call if options[:before]

  cmd = "BUNDLE_GEMFILE=Gemfile-#{FONTANA_ENV} bundle exec rake #{name} -v -t"
  if Rake.application.options.trace
    cmd << " --trace"
  end
  Dir.chdir(FONTANA_HOME) do
    system!(cmd)
  end

  options[:after].call if options[:after]
end

def fontana_task(name, options = {})
  full_name = (@namespaces + [name]).join(':')
  TASK_OPTIONS[full_name] = options
  task name do
    call_fontana_task(full_name)
  end
end

def namespace_with_fontana(name, target = nil, &block)
  @namespaces ||= []
  @namespaces.push(target || name)
  begin
    namespace(name, &block)
  ensure
    @namespaces.pop
  end
end

namespace :vendor do
  namespace :fontana do

    desc "clear"
    task :clear do
      FileUtils.rm_rf(vendor_fontana)
    end

    desc "clone"
    task :clone => :"vendor:fontana:clear" do
      raise "$FONTANA_REPO_URL is required" unless fontana_repo_url
      FileUtils.mkdir_p(vendor_dir)
      Dir.chdir(vendor_dir) do
        system!("git clone #{fontana_repo_url}")
      end
      Dir.chdir(vendor_fontana) do
        system!("git checkout #{fontana_branch}")
        FileUtils.cp(File.join(root_dir, "spec/server_config/mongoid.yml"), "config/mongoid.yml")
        FileUtils.cp("config/project.yml.erb.example", "config/project.yml.erb")
        system!("BUNDLE_GEMFILE=Gemfile-#{FONTANA_ENV} bundle install")
      end
      Rake::Task["deploy:reset"].execute
    end

    desc "update"
    task :update do
      Dir.chdir(vendor_fontana) do
        system!("git fetch origin")
        system!("git checkout origin/#{fontana_branch}")
        system!("BUNDLE_GEMFILE=Gemfile-#{FONTANA_ENV} bundle install")
        system!("BUNDLE_GEMFILE=Gemfile-#{FONTANA_ENV} bundle exec rake db:drop")
      end
      Rake::Task["deploy:update"].execute
    end

    desc "prepare"
    task :prepare do
      if Dir.exist?(vendor_fontana)
        Rake::Task["vendor:fontana:update"].execute
      else
        Rake::Task["vendor:fontana:clone"].execute
      end
    end
  end

  desc "prepare vendor/fontana "
  task :fontana => :"vendor:fontana:prepare"
end


namespace_with_fontana :deploy, :"app:deploy" do

  set_url_and_branch = ->{
    ENV['URL'] ||= `git remote -v`.scan(/origin\s+(.+?)\s/).flatten.uniq.first
    ENV['BRANCH'] ||= `git status`.scan(/^.+\sbranch\s(.+)\s*$/).flatten.first
  }

  desc "deploy:setup deploy:update"
  fontana_task :reset, before: set_url_and_branch

  desc "drop DB, initialize, clear workspaces, clone, checkout branch. $URL required."
  fontana_task :setup, before: set_url_and_branch

  desc "fetch, checkout, build app_seed and migrate."
  fontana_task :update
end

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


namespace_with_fontana :server, :libgss_test do
  desc "luanch HTTP server"
  fontana_task :launch_http_server

  desc "luanch HTTP server daemon"
  fontana_task :launch_http_server_daemon

  desc "luanch HTTPS server"
  fontana_task :launch_https_server

  desc "luanch HTTPS server daemon"
  fontana_task :launch_https_server_daemon

  desc "luanch server"
  fontana_task :launch_server

  desc "luanch server daemons"
  fontana_task :launch_server_daemons

  desc "shutdown server daemons"
  fontana_task :shutdown_server_daemons

  desc "check daemon alive"
  fontana_task :check_daemon_alive
end



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



desc "run spec with server_daemons"
task :spec_with_server_daemons => [:"vendor:fontana:prepare"] do
  Rake::Task["server:launch_server_daemons"].execute
  begin
    sleep(5) # 実際にポートをLINSTENするまで待つ
    Rake::Task["spec"].execute
  ensure
    Rake::Task["server:shutdown_server_daemons"].execute
  end
end

task :default => :spec_with_server_daemons
