# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Anton Sozontov.
# Copyright, 2022, by Samuel G. D. Williams. <http://www.codeotaku.com>

require 'samovar'
require 'async/container'
require_relative '../job'

module Async
  module Runner
    module Commands
      class Run < Samovar::Command
        MAX_FIBERS = 1000

        # The command line options.
        # @attribute [Samovar::Options]
        options do
          option '--verbose | --quiet', "Verbosity of output for debugging.", key: :logging
          option '-h/--help', "Print out help information."
          option '-v/--version', "Print out the application version."
          option '--restart', "Restart containers if they fail"

          option '--forked | --threaded | --hybrid', "Select a specific parallelism model.", key: :container, default: :forked

          option '-n/--count <count>', "Number of instances to start.", default: Async::Container.processor_count, type: Integer

          option '--forks <count>', "Number of forks (hybrid only).", type: Integer
          option '--threads <count>', "Number of threads (hybrid only).", type: Integer
          option '-j/--jobs <count>', "Maximum number of async, parallel jobs.", type: Integer, default: MAX_FIBERS
          option '-f/--file <file>', "File to run in containers"
        end

        # Prepare the environment and invoke the sub-command.
        def call
          return print_usage unless file?
          Async::Runner::Controller.run(self)
        end

        def file?
          return false if !file || file == '-f' || file == '--file'
          File.readable?(file)
        end

        def file
          @options[:file]
        end

        # The container class to use.
        def container_class
          case @options[:container]
          when :threaded
            Async::Container::Threaded
          when :hybrid
            Async::Container::Hybrid
          else
            Async::Container::Forked
          end
        end

        def container_options
          if @options[:container] == :hybrid
            options.slice(:count, :forks, :threads, :name, :restart, :key)
          else
            options.slice(:count, :name, :restart, :key)
          end
        end

        def job_class
          Async::Runner::Job
        end

        # Whether verbose logging is enabled.
        # @returns [Boolean]
        def verbose?
          @options[:logging] == :verbose
        end

        # Whether quiet logging was enabled.
        # @returns [Boolean]
        def quiet?
          @options[:logging] == :quiet
        end
      end
    end
  end
end
