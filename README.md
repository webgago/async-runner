# Async::Runner

Provides containers which implement parallelism for clients and servers.

[![Development Status](https://github.com/webgago/async-runner/workflows/Development/badge.svg)](https://github.com/webgago/async-runner/actions?workflow=Development)

## Features

This gem is based on [Async::Container](https://github.com/socketry/async-container) and inherits all its features.

- Supports multi-process, multi-thread and hybrid containers.
- Automatic scalability based on physical hardware.
- Direct integration with systemd using $NOTIFY_SOCKET.
- Internal process readiness protocol for handling state changes.
- Automatic restart of failed processes.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'async-runner'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install async-runner

## Usage

```bash
bundle exec async-runner --help
#    async-runner [-h/--help] [-v/--version] <command>
#            Scalable multi-thread multi-process container
#    
#            [-h/--help]     Print out help information.                
#            [-v/--version]  Print out the application version.         
#            <command>       Only ["run", Async::Runner::Commands::Run].
#    
#            run [--verbose | --quiet] [-h/--help] [-v/--version] [--restart] [--forked | --threaded | --hybrid] [-n/--count <count>] [--forks <count>] [--threads <count>] [-j/--jobs <count>] [-f/--file <file>]
#                    [--verbose | --quiet]               Verbosity of output for debugging.     
#                    [-h/--help]                         Print out help information.            
#                    [-v/--version]                      Print out the application version.     
#                    [--restart]                         Restart containers if they fail        
#                    [--forked | --threaded | --hybrid]  Select a specific parallelism model.     (default: forked)
#                    [-n/--count <count>]                Number of instances to start.            (default: 10)    
#                    [--forks <count>]                   Number of forks (hybrid only).         
#                    [--threads <count>]                 Number of threads (hybrid only).       
#                    [-j/--jobs <count>]                 Maximum number of async, parallel jobs.  (default: 1000)  
#                    [-f/--file <file>]                  File to run in containers              
```

Let's suppose you have the following script:

```ruby
setup do
  logger.info "Setup phase. Executed once..."
end

run do |job|
  logger.info "Run"

  10.times do |i|
    job.async do
      sleep 1
      logger.info job, "Done #{i}"
    end
  end
  logger.info "Done"
end
```

Run this script with the following command:

```bash
bundle exec async-runner --count 1 --jobs 2 -f script.rb
```

This command makes sure there are only 2 async jobs at a time. In other words it runs 2 jobs, waits 2 seconds and runs 2 more jobs. 
You can limit the number of jobs with `-j/--jobs` option.

```
 0.04s     info: Setup phase. Executed once... [ec=0x2bc] [pid=38433] [2022-10-25 20:00:56 +0300]
 0.05s     info: Run [ec=0x2d0] [pid=38482] [2022-10-25 20:00:56 +0300]
 1.05s     info: Runner [oid=0x30c] [ec=0x320] [pid=38482] [2022-10-25 20:00:57 +0300]
               | Done 0
 1.05s     info: Runner [oid=0x30c] [ec=0x348] [pid=38482] [2022-10-25 20:00:57 +0300]
               | Done 1
 2.05s     info: Runner [oid=0x30c] [ec=0x370] [pid=38482] [2022-10-25 20:00:58 +0300]
               | Done 2
 2.05s     info: Runner [oid=0x30c] [ec=0x398] [pid=38482] [2022-10-25 20:00:58 +0300]
               | Done 3
 3.05s     info: Runner [oid=0x30c] [ec=0x3c0] [pid=38482] [2022-10-25 20:00:59 +0300]
               | Done 4
 3.05s     info: Runner [oid=0x30c] [ec=0x3e8] [pid=38482] [2022-10-25 20:00:59 +0300]
               | Done 5
 4.06s     info: Runner [oid=0x30c] [ec=0x410] [pid=38482] [2022-10-25 20:01:00 +0300]
               | Done 6
 4.06s     info: Runner [oid=0x30c] [ec=0x438] [pid=38482] [2022-10-25 20:01:00 +0300]
               | Done 7
 4.06s     info: Done [ec=0x2d0] [pid=38482] [2022-10-25 20:01:00 +0300]
 5.06s     info: Runner [oid=0x30c] [ec=0x460] [pid=38482] [2022-10-25 20:01:01 +0300]
               | Done 8
 5.06s     info: Runner [oid=0x30c] [ec=0x474] [pid=38482] [2022-10-25 20:01:01 +0300]
               | Done 9
 5.07s     info: Async::Container::Forked [oid=0x2f8] [ec=0x30c] [pid=38433] [2022-10-25 20:01:01 +0300]
               | #<Async::Container::Process examples/script.rb> exited with pid 38482 exit 0
```

### Script DSL

```ruby
setup do
  # runs in the parent process/thread...
end

run do |job|
  # runs in a child process/thread...

  job.async do
    # your async jobs goes here...
  end
  # other code
end

run do 
  # this block waits the first one to be finished...
end

teardown do
  # runs in the parent process/thread...
end
```

### Standalone script example

```ruby
#!/usr/bin/env bundle exec async-runner run -f
# frozen_string_literal: true

run do 
  # your code goes here...
end
```

```bash
> chmod +x ./script.rb
> ./script.rb 
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/webgago/async-runner. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/async-runner/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Async::Runner project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/async-runner/blob/master/CODE_OF_CONDUCT.md).
