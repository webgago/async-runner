require 'async/barrier'
require 'async/semaphore'

module Async
	module Runner
		class Job
			include Console

			attr_reader :block, :options
			attr_accessor :job_id

			def initialize(file, **options)
				path = File.realpath(file)
				@options = options
				@barrier = Async::Barrier.new
				@semaphore = Async::Semaphore.new(options[:jobs], parent: @barrier)
				@rescue_handlers = []
				@blocks = []
				instance_eval File.read(path), path
			end

			def instances_count
				@options[:count]
			end

			def job
				self
			end

			def run(&block)
				@blocks << block
			end

			def execute
				@blocks.each do |block|
					with_exception_handler { block.call(job) }
					@barrier.wait
				end
				@barrier.wait
			end

			def async
				@semaphore.async do
					yield
				end
			end

			def each_task(array, subject="job #{job_id} progress", progress: false)
				progress_bar = logger.progress(subject, array.size) if progress

				array.each do |i|
					async do
						yield i
						progress_bar.increment if progress
					end
				end
			end

			def setup(&block)
				if block_given?
					@setup_block = block
				else
					@setup_block&.call job
				end
			end

			def teardown(&block)
				if block_given?
					@teardown_block = block
				else
					@teardown_block&.call job
				end
			end

			def self.to_s
				"Runner"
			end

			def rescue_from(klass, &block)
				(@rescue_handlers ||= []) << [klass, block]
			end

			def handle_exception(exception)
				@rescue_handlers.each do |klass, block|
					block.call(exception) if exception.class <= klass
				end
			end

			def with_exception_handler
				yield
			rescue => e
				handle_exception e
			end
		end
	end
end
