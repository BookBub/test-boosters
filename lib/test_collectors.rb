require "json"
require "ox"

module TestCollectors
  require_relative "test_collectors/collectors/base"
  require_relative "test_collectors/collectors/junit"
  require_relative "test_collectors/collectors/rspec_semaphore"

  ROOT_PATH = File.absolute_path(File.dirname(__FILE__) + "/..")
end
