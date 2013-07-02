module Fontana
  module ServerRake

    include Fontana::CommandUtils

    module_function

    def task_options
      @task_options ||= {}
    end

    def call_fontana_task(name)
      options = task_options[name]
      options[:before].call if options[:before]

      cmd = "BUNDLE_GEMFILE=#{Fontana.gemfile} bundle exec rake #{name}"
      if Rake.application.options.trace
        cmd << " --trace -v"
      end
      Dir.chdir(Fontana.home) do
        system!(cmd)
      end

      options[:after].call if options[:after]
    end

    def fontana_task(name, options = {})
      full_name = (@namespaces + [name]).join(':')
      task_options[full_name] = options
      task name do
        call_fontana_task(full_name)
      end
    end

    def namespace_with_fontana(name, target = nil, &block)
      @namespaces ||= []
      @namespaces.push(target || name)
      begin
        namespace(name, &block)
      ensure
        @namespaces.pop
      end
    end

  end
end
