# -*- coding: utf-8 -*-
require "rspec/core/rake_task"
require 'fontana_client_support/tasks'

RSpec::Core::RakeTask.new(:spec)

FontanaClientSupport.config do |c|
  c.root_dir = File.expand_path("..", __FILE__)
  c.deploy_strategy = (ENV['SYNC_DIRECTLY'] =~ /^true$|^on$/i) ? :sync : :scm
end

task :default => :spec_with_server_daemons
