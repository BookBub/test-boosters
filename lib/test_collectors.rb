require "json"
require "ox"

module TestCollectors
  require "test_collectors/collectors/base"
  require "test_collectors/collectors/junit"
  require "test_collectors/collectors/rspec_semaphore"

  ROOT_PATH = File.absolute_path(File.dirname(__FILE__) + "/..")
end
