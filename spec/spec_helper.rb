require 'libgss'
require 'fontana_client_support'

Dir[File.expand_path("../support/**/*.rb", __FILE__)].each {|f| require f}

if ENV['SYNC_DIRECTLY'] =~ /yes|on|true/i
  Fontana::CommandUtils::system!("rake deploy:sync:update")
end

RSpec.configure do |config|
end
