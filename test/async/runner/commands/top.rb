# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Anton Sozontov.

require 'async/runner/commands/top'
require 'async/runner/controller'
require 'async/runner/job'

describe Async::Runner::Commands::Top do
  let(:command) { subject.parse(input) }
  let(:usage_regexp) { %r(\[-h/--help\] \[-v/--version\] <command>) }
  let(:version_regexp) { /\d+\.\d+\.\d+/ }

  with "--version" do
    let(:command) { subject.new ["--version"] }

    it 'prints version' do
      expect_stderr do
        command.call
      end.to be =~ version_regexp
    end
  end

  with "-v" do
    let(:command) { subject.new ["-v"] }

    it 'prints version' do
      expect_stderr do
        command.call
      end.to be =~ version_regexp
    end
  end

  with "-h" do
    let(:command) { subject.new ["-h"] }

    it 'prints usage' do
      expect_stderr do
        command.call
      end.to be =~ usage_regexp
    end
  end

  with "--help" do
    let(:command) { subject.new ["--help"] }

    it 'prints usage' do
      expect_stderr do
        command.call
      end.to be =~ usage_regexp
    end
  end

  with "run" do
    let(:command) { subject.new ["run"] }

    it 'prints usage' do
      expect { command.call }.to raise_exception Samovar::MissingValueError
    end
  end

  def expect_stderr
    original_stderr = $stderr
    stderr = StringIO.new
    $stderr = stderr
    yield
    $stderr = original_stderr
    expect(stderr.string)
  end
end
