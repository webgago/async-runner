# frozen_string_literal: true

require "async/runner/controller"
require "async/runner/commands/run"

describe Async::Runner::Controller do
  let(:controller_path) {File.expand_path(".dots.rb", __dir__)}
  let(:command) { Async::Runner::Commands::Run["-n", "1", "--threaded", "-f", controller_path] }
  let(:controller) {subject.new(command)}

  with '#start' do
    it "can start up a container" do
      expect(controller).to receive(:setup)

      controller.start

      expect(controller).to be(:running?)
      expect(controller.container).not.to be_nil

      controller.stop

      expect(controller).not.to be(:running?)
      expect(controller.container).to be_nil
    end

    it "can spawn a reactor" do
      def controller.setup(container)
        container.async do |task|
          task.sleep 1
        end
      end

      controller.start

      statistics = controller.container.statistics

      expect(statistics.spawns).to be == 1

      controller.stop
    end

    it "propagates exceptions" do
      def controller.setup(container)
        raise "Boom!"
      end

      expect do
        controller.run
      end.to raise_exception(Async::Container::SetupError)
    end
  end

  with 'signals' do
    let(:pipe) {IO.pipe}
    let(:input) {pipe.first}
    let(:output) {pipe.last}
    let(:pid) {@pid}

    def before
      @pid = Process.spawn("exe/async-runner", "run", "--count", "1", "--threaded", "--file", controller_path, out: output)
      output.close

      super
    end

    def after
      Process.kill(:TERM, @pid)
      Process.wait(@pid)

      super
    end

    it "restarts children when receiving SIGHUP" do
      expect(input.read(1)).to be == '.'

      Process.kill(:HUP, pid)

      expect(input.read(2)).to be == 'I.'
    end

    it "exits gracefully when receiving SIGINT" do
      expect(input.read(1)).to be == '.'

      Process.kill(:INT, pid)

      expect(input.read).to be == 'I'
    end

    it "exits gracefully when receiving SIGTERM" do
      expect(input.read(1)).to be == '.'

      Process.kill(:TERM, pid)

      expect(input.read).to be == 'T'
    end
  end
end
