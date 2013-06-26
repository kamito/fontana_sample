require 'libgss'

Dir[File.expand_path("../support/**/*.rb", __FILE__)].each {|f| require f}

if ENV['SYNC_DIRECTLY'] =~ /yes|on|true/i
  unless system("rake sync:client")
    raise "rake sync:client ERROR!"
  end
end

RSpec.configure do |config|
end
