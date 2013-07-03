# -*- coding: utf-8 -*-
require "rspec/core/rake_task"
require 'fontana_client_support/tasks'

RSpec::Core::RakeTask.new(:spec)

FontanaClientSupport.root_dir = File.expand_path("..", __FILE__)

task :default => :spec_with_server_daemons
