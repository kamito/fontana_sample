# -*- coding: utf-8 -*-
require "rspec/core/rake_task"

require 'fileutils'

$LOAD_PATH << File.expand_path("../lib", __FILE__)

require 'fontana_client_support'
require 'fontana_client_support/tasks'

RSpec::Core::RakeTask.new(:spec)

FontanaClientSupport.root_dir = File.expand_path("..", __FILE__)

ENV['DEFAULT_HTTP_PORT' ] ||= '3000'
ENV['DEFAULT_HTTPS_PORT'] ||= '3001'

Fontana.repo_url = ENV['FONTANA_REPO_URL']
Fontana.branch   = ENV['FONTANA_BRANCH'] || 'master'

Fontana.home = ENV['FONTANA_HOME'] || (Dir.exist?(FontanaClientSupport.vendor_fontana) or Fontana.repo_url) ? FontanaClientSupport.vendor_fontana : nil
Fontana.gemfile  = ENV['FONTANA_GEMFILE'] || "Gemfile-LibgssTest"

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
