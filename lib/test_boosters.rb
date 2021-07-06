require "uri"
require "open3"
require "optparse"
require "json"

module TestBoosters
  require_relative "test_boosters/version"
  require_relative "test_boosters/cli_parser"
  require_relative "test_boosters/logger"
  require_relative "test_boosters/shell"

  require_relative "test_boosters/project_info"
  require_relative "test_boosters/job"
  require_relative "test_boosters/files/distributor"
  require_relative "test_boosters/files/leftover_files"
  require_relative "test_boosters/files/split_configuration"
  require_relative "test_boosters/boosters/base"
  require_relative "test_boosters/boosters/rspec"
  require_relative "test_boosters/boosters/cucumber"
  require_relative "test_boosters/boosters/go_test"
  require_relative "test_boosters/boosters/pytest"
  require_relative "test_boosters/boosters/ex_unit"
  require_relative "test_boosters/boosters/minitest"

  ROOT_PATH = File.absolute_path(File.dirname(__FILE__) + "/..")
end
