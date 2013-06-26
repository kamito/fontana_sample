# -*- coding: utf-8 -*-
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

FONTANA_HOME = ENV['FONTANA_HOME'] || File.expand_path("../../fontana", __FILE__)
FONTANA_ENV  = ENV['FONTANA_ENV'] || "LibgssTest"

ENV['DEFAULT_HTTP_PORT'] ||= '3000'
ENV['DEFAULT_HTTPS_PORT'] ||= '3001'

TASK_OPTIONS = {}

def system!(cmd)
  puts "now executing: #{cmd}"
  # res = `#{cmd} 2>&1`
  # puts res

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

  cmd = "BUNDLE_GEMFILE=Gemfile-#{FONTANA_ENV} bundle exec rake #{name}"
  if Rake.application.options.trace
    cmd << " --trace"
  end
  Dir.chdir(FONTANA_HOME){ system!(cmd) }

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
