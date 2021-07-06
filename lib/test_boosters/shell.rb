module TestBoosters
  module Shell
    module_function

    # :reek:TooManyStatements
    def execute(command, options = {})
      TestBoosters::Logger.info("Running command: #{command}")

      puts command unless options[:silent] == true

      with_clean_env do
        run_command(command)
      end

      signaled    = $?.signaled?
      termsig     = $?.termsig
      exited      = $?.exited?
      exit_status = $?.exitstatus

      TestBoosters::Logger.info("Command signaled with: #{termsig}") if signaled
      TestBoosters::Logger.info("Command exited : #{exited}")
      TestBoosters::Logger.info("Command finished, exit status : #{exit_status}")

      exit_status
    end

    def evaluate(command)
      with_clean_env { `#{command}` }
    end

    def with_clean_env
      if defined?(Bundler) && Bundler.method_defined?(:with_clean_env)
        Bundler.with_clean_env { yield } 
      else
        yield
      end
    end

    def display_title(title)
      puts
      puts "=== #{title} ===="
      puts
    end

    def display_files(title, files)
      puts "#{title} (#{files.count} files):"
      puts

      files.each { |file| puts "- #{file}" }

      puts "\n"
    end

    def run_command(command)
      Open3.popen3(command) do |stdin, out, err, thread|
        t_out = Thread.new do
          out.each(&method(:puts))
        end

        t_err = Thread.new do
          err.each(&method(:puts))
        end

        [t_out, t_err].each(&:join)

        return thread.value
      end
    end
  end
end
