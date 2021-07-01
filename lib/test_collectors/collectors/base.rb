module TestCollectors
  module Collectors
    class Base

      # Merge test booster split configuration files generated per-node into one per-job
      #
      # generates a json file containing an array of one {"files": ["spec/file/paths"]} per job
      # [
      #   { "files": ["spec/a_spec.rb", "spec/b_spec.rb"] },
      #   { "files": ["spec/c_spec.rb", "spec/d_spec.rb"] },
      #   { "files": ["spec/e_spec.rb"] }
      # ]

      def initialize
        @split_level ||= ENV.fetch("SPLIT_LEVEL", "file").downcase
        @split_files_dir ||= ENV.fetch("SPLIT_CONFIGS_DIR", "rspec_booster")
      end

      def ingest_report
        raise NotImplementedError
      end

      def run
        Dir.chdir(@split_files_dir) do
          Dir.each_child(Dir.pwd) do |test_job|
            next unless File.directory? File.join(Dir.pwd, test_job)

            merged_examples, number_of_jobs = parse_container_timing_files(test_job)

            # sort examples by timing desc
            timing_sets = merged_examples.sort_by {|_, run_time| run_time}.reverse
            timing_bins = harmonic_binpack(number_of_jobs, timing_sets)

            display_bin_stats(test_job, timing_bins)
            generate_split_configs(test_job, timing_bins)
          end
        end

        true
      end

      def parse_container_timing_files(test_job)
        merged_examples = Hash.new(0)
        number_of_jobs = 0

        Dir.chdir(test_job) do
          Dir.each_child(Dir.pwd) do |job_report|
            number_of_jobs += 1
              merged_examples = ingest_report(job_report, merged_examples)
          end
        end
        return merged_examples, number_of_jobs
      end

      def harmonic_binpack(number_of_bins, timing_sets, timing_bins: nil)
        timing_bins ||= Array.new(number_of_bins){
          {
            specs: [],
            runtime: 0,
          }
        }

        leftover_timings = []

        # iterating over timings in order of slowest to fastest
        # and bins from shortest total runtime to longest runtime
        timing_sets.each_slice(2).each do |timing_set|
          timing_set.each_with_index do |timing_tuple, i|
            spec_file = timing_tuple.first
            spec_timing = timing_tuple.last

            timing_bin_index = i % number_of_bins
            timing_bin = timing_bins[timing_bin_index]

            # if we're in the slower half of the timing set
            # check to see if adding the current spec to the current bin
            # will make this spec slower than the bin in the midpoint of the list
            # and if so, put it into the leftover set to be re-processed on the next iteration
            if i > (number_of_bins / 2)
              midpoint_bin = timing_bins[(number_of_bins / 2)]
              if midpoint_bin[:runtime] < timing_bin[:runtime] + spec_timing
                leftover_timings << timing_tuple
                next
              end
            end

            timing_bin[:specs] << spec_file
            timing_bin[:runtime] += spec_timing
          end

          timing_bins.sort_by! { |timing_bin| timing_bin[:runtime] }
        end

        if leftover_timings.length > 0
          return harmonic_binpack(number_of_bins, leftover_timings, timing_bins: timing_bins)
        end

        return timing_bins
      end

      def display_bin_stats(test_job, timing_bins)
        # this is just for display/stats, so round to 2 decimal places
        timing_max = timing_bins.last[:runtime].round(2)
        timing_min = timing_bins.first[:runtime].round(2)
        timing_diff = (timing_max - timing_min).round(2)

        puts
        puts "###### #{test_job} ######"
        puts " split timing range: #{timing_max}s - #{timing_min}s (#{timing_diff}s diff)"
        puts " container split timings:"

        timing_bins.each_with_index do |bin, i|
          puts " - bin #{i}: #{bin[:runtime].round(2)}s (#{bin[:specs].length} specs)"
          puts "   slowest: #{bin[:specs].last}"
        end
      end

      def generate_split_configs(test_job, timing_bins)
        split_configuration = []
        split_configuration_output = "#{test_job}_split_configuration.json"

        timing_bins.each do |timing_bin|
          split_configuration << { "files" => timing_bin[:specs] }
        end

        File.open(split_configuration_output, 'w') do |file|
          JSON.dump(split_configuration, file)
        end
      end
    end
  end
end
