module TestBoosters
  module Boosters
    class Cucumber < Base

      FILE_PATTERN = "features/**/*.feature".freeze

      def initialize
        super(FILE_PATTERN, nil, split_configuration_path, "bundle exec cucumber")
      end

      def display_header
        super

        TestBoosters::ProjectInfo.display_ruby_version
        TestBoosters::ProjectInfo.display_bundler_version
        TestBoosters::ProjectInfo.display_cucumber_version
      end

      def report_path
        @report_path ||= ENV["REPORT_PATH"] || "#{ENV["HOME"]}/cucumber_report.json"
      end

      def split_configuration_path
        ENV["CUCUMBER_SPLIT_CONFIGURATION_PATH"] || "#{ENV["HOME"]}/cucumber_split_configuration.json"
      end

    end
  end
end
