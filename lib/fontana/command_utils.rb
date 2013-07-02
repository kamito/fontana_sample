module Fontana
  module CommandUtils

    module_function

    def system!(cmd)
      puts "now executing: #{cmd}"

      IO.popen("#{cmd} 2>&1") do |io|
        while line = io.gets
          puts line
        end
      end

      if $?.exitstatus != 0
        exit(1)
      end
    end

  end
end
