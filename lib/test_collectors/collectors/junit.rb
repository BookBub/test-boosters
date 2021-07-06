module TestCollectors
  module Collectors
    class Junit < Base

      def initialize
        super
      end

      def ingest_report(job_report, merged_examples={})
        junit = Ox.load(File.read(job_report), mode: :hash)

        # python adds this extra key
        if junit[:testsuites]
          suites = junit[:testsuites][:testsuite]
        else
          suites = junit[:testsuite]
        end

        suites.each do |suite|
          next unless suite[:testcase]
          suite[:testcase].each do |testcase|
            filepath = testcase[:file]
            merged_examples[filepath] ||= 0
            merged_examples[filepath] += testcase[:time].to_f
          end
        end

        merged_examples
      end

    end
  end
end
