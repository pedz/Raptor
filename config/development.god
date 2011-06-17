# run with: god -c /path/to/this/file.god -D
# 
# This is the actual config file used to keep the thin processes
# running

RAILS_ROOT = "/Users/pedzan/Source/Rails/raptor"
God.pid_file_directory = File.join(RAILS_ROOT, "tmp/pids")

def common(w)
  w.log = File.join(RAILS_ROOT, "log/#{w.name}.out")
  w.err_log = File.join(RAILS_ROOT, "log/#{w.name}.err")
  w.dir = RAILS_ROOT
  w.pid_file = w.pid_file
  w.start_grace = 10.seconds
  w.restart_grace = 10.seconds
  w.behavior(:clean_pid_file)
  w.group = 'raptor'
end

$beanstalkd = nil

# God.watch do |w|
#   $beanstalkd = w
#   w.name = "beanstalkd-raptor"
#   common(w)
#   w.interval = 5.minutes
#   w.start = "/usr/local/bin/beanstalkd"
#   w.stop = "kill -INT #{w.pid}"

#   w.start_if do |start|
#     start.condition(:process_running) do |c|
#       c.interval = 5.seconds
#       c.running = false
#     end
#   end
  
#   w.restart_if do |restart|
#     restart.condition(:memory_usage) do |c|
#       c.above = 150.megabytes
#       c.times = [3, 5] # 3 out of 5 intervals
#     end
  
#     restart.condition(:cpu_usage) do |c|
#       c.above = 50.percent
#       c.times = 5
#     end
#   end
  
#   # lifecycle
#   w.lifecycle do |on|
#     on.condition(:flapping) do |c|
#       c.to_state = [:start, :restart]
#       c.times = 5
#       c.within = 5.minute
#       c.transition = :unmonitored
#       c.retry_in = 10.minutes
#       c.retry_times = 5
#       c.retry_within = 2.hours
#     end
#   end
# end

%w{5000 5001}.each do |port|
  God.watch do |w|
    w.name = "raptor-thin-#{port}"
    common(w)
    w.interval = 1.minute
    w.start = "script/rvm-wrapper thin --daemonize --port #{port} \
      --environment development --prefix /raptor --log #{w.log} \
      --pid #{w.pid_file} --chdir #{w.dir} start"
    w.stop = "script/rvm-wrapper thin --pid #{w.pid_file} stop"
    w.restart = "script/rvm-wrapper thin --pid #{w.pid_file} stop"

    w.start_if do |start|
      start.condition(:process_running) do |c|
        c.interval = 5.seconds
        c.running = false
      end
    end
    
    w.restart_if do |restart|
      restart.condition(:memory_usage) do |c|
        c.above = 150.megabytes
        c.times = [3, 5] # 3 out of 5 intervals
      end
    
      restart.condition(:cpu_usage) do |c|
        c.above = 50.percent
        c.times = 5
      end
    end
    
    # lifecycle
    w.lifecycle do |on|
      on.condition(:flapping) do |c|
        c.to_state = [:start, :restart]
        c.times = 5
        c.within = 5.minute
        c.transition = :unmonitored
        c.retry_in = 10.minutes
        c.retry_times = 5
        c.retry_within = 2.hours
      end
    end
  end
end
