setup do
  logger.info "Setup phase. Executed once..."
end

rescue_from Async::Container::Interrupt do
  $stdout.write("I")
end

rescue_from Async::Container::Terminate do
  $stdout.write("T")
end

limit(1)
progress(total: 100)

run do |job|
  sleep 1

  $stdout.write "."
  $stdout.flush

  sleep
end
