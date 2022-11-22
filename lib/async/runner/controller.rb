require 'async/container/controller'

module Async
	module Runner
		class Controller < Async::Container::Controller
			def self.run(command)
				new(command).run
			end

			def initialize(command)
				@command = command
				super()
			end

			def create_container
				@command.container_class.new
			end

			def create_job
				@command.job_class.new(@command.file, **@command.options)
			end

			def setup(container)
				@job = create_job
				@job.setup

				container.run name: @command.file, **@command.container_options do |instance, id:|
					@job.job_id = id
					instance.ready!
					Sync do
						@job.execute
					end
				rescue Exception => e
					@job.handle_exception(e)
				end

				container.wait
				@job.teardown
			end
		end
	end
end
