require 'fontana'

module FontanaClientSupport

  class << self
    attr_accessor :root_dir

    def vendor_dir
      @vendor_dir ||= File.join(root_dir, "vendor")
    end

    def vendor_fontana
      @vendor_fontana ||= File.join(vendor_dir, "fontana")
    end
  end
end
