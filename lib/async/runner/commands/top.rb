# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Anton Sozontov.
# Copyright, 2022, by Samuel G. D. Williams. <http://www.codeotaku.com>

require 'samovar'
require 'async/container'
require_relative './run'

module Async
  module Runner
    module Commands
      class Top < Samovar::Command
        self.description = "Scalable multi-thread multi-process container"

        # The command line options.
        # @attribute [Samovar::Options]
        options do
          option '-h/--help', "Print out help information."
          option '-v/--version', "Print out the application version."
        end

        nested :command, {
          'run' => Run
        }

        # Prepare the environment and invoke the sub-command.
        def call
          if @options[:version]
            $stderr.puts "#{self.name} v#{Async::Runner::VERSION}"
            return
          end

          if @options[:help] || !@command
            self.print_usage
          else
            @command.call
          end
        end

        private
      end
    end
  end
end
