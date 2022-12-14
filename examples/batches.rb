#!/usr/bin/env bundle exec async-runner run -f
# frozen_string_literal: true

class MyError < StandardError
end

queues = Hash.new { |hash, key| hash[key] = [] }
TASKS = 1000

setup do
  logger.info "Prepare queue for #{instances_count} instances..."
  progress = logger.progress("queue", TASKS)
  iterator = instances_count.times.cycle

  TASKS.times do |i|
    queues[iterator.next] << i
    progress.increment
  end

  logger.info "#{TASKS} Ready"
  logger.info "Starting instances..."
end

rescue_from MyError do
  logger.error("ð£ð£ð£ Error ð£ð£ð£")
end

run do
  each_task queues[job_id], progress: true do |item|
    sleep 1
  end
  raise MyError if rand < 0.5
  logger.info "Done ð"
end

run do
  logger.info "Cleaning up instanceð§¹ð§¹ð§¹"
  sleep 10
  logger.info "Instance cleaned âï¸"
end

teardown do
  logger.info "Teardown ð¥³"
end
