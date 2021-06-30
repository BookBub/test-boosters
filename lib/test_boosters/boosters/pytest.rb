module TestBoosters
  module Boosters
    class Pytest < Base
      def initialize
        super(file_pattern, nil, split_configuration_path, command)
      end

      def split_configuration_path
        ENV["PYTEST_SPLIT_CONFIGURATION_PATH"] || "#{ENV["HOME"]}/pytest_split_configuration.json"
      end

      def file_pattern
        ENV["TEST_BOOSTERS_PYTEST_TEST_FILE_PATTERN"] || "test/**/*_test.py"
      end

      def command
        @command ||= "python -m pytest #{ENV["TB_PYTEST_OPTIONS"]} "
      end
    end
  end
end
