require 'libgss'

Dir[File.expand_path("../support/**/*.rb", __FILE__)].each {|f| require f}

if ENV['SYNC_DIRECTLY'] =~ /yes|on|true/i
  unless system("rake deploy:sync:update")
    raise "rake deploy:sync:update ERROR!"
  end
end

RSpec.configure do |config|
end
