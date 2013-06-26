require 'libgss'

Dir[File.expand_path("../support/**/*.rb", __FILE__)].each {|f| require f}

if ENV['UPDATE_SCRIPT_DIRECTLY'] =~ /yes|on|true/i
  unless system("rake source:update_scripts")
    raise "rake source:update_scripts ERROR!"
  end
end

RSpec.configure do |config|
end
