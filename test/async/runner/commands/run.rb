# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Anton Sozontov.

require 'async/runner/commands/run'
require 'async/runner/controller'
require 'async/runner/job'

describe Async::Runner::Commands::Run do
  let(:command) { subject.parse(input) }

  with "defaults" do
    let(:input) { [] }

    it "is not verbose" do
      expect(command.verbose?).to be == false
    end

    it "is not quiet" do
      expect(command.quiet?).to be == false
    end

    it "is forked" do
      expect(command.container_class).to be == Async::Container::Forked
    end

    it "spawns Async::Container.processor_count forks" do
      expect(command.container_options[:count]).to be == Async::Container.processor_count
    end

    it "is runs Async::Runner::Job" do
      expect(command.job_class).to be == Async::Runner::Job
    end
  end

  with "hybrid" do
    let(:input) { ["--hybrid"] }

    it "is hybrid container" do
      expect(command.container_class).to be == Async::Container::Hybrid
    end

    it "spawns Async::Container.processor_count forks" do
      expect(command.container_options[:count]).to be == Async::Container.processor_count
    end
  end

  with "threaded" do
    let(:input) { ["--threaded"] }

    it "is threaded container" do
      expect(command.container_class).to be == Async::Container::Threaded
    end
  end

  with "given script file" do
    let(:input) { %w[--threaded --file script.rb] }

    it 'runs a script' do
      expect { command.call }.to raise_exception(Async::Container::SetupError)
    end
  end

  with "version" do
    let(:command) { subject.new ["--version"] }

    it 'runs a script' do
      command
    end
  end
end
