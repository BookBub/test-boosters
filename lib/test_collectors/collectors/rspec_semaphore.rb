module TestCollectors
  module Collectors
    class RspecSemaphore < Base

      def initialize
        super
      end

      def ingest_report(job_report, merged_examples)
        merged_examples ||= Hash.new(0)
        child_json = JSON.parse(File.read(job_report))
        child_json['examples'].each do |example|
          merged_examples[example_path(example)] += example['run_time']
        end
        merged_examples
      end

      private

      def example_path(example)
        if @split_level == 'spec'
          path = "#{example['file_path']}:#{example['line_number']}"
        else
          path = example['file_path']
        end

        path
      end
    end
  end
end
