
module Fontana
  autoload :CommandUtils, 'fontana/command_utils'
  autoload :ServerRake  , 'fontana/server_rake'

  class << self
    attr_accessor :home
    attr_accessor :gemfile

    attr_accessor :repo_url
    attr_accessor :branch
  end
end
