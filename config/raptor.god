# -*- coding: utf-8 -*-
# run with: god -c /path/to/this/file.god -D
# 
# This is the actual config file used to keep the thin processes
# running

require 'pathname'
require 'yaml'
require 'socket'

RAILS_ROOT = Pathname.new(__FILE__).dirname.dirname.to_s
god_configs = YAML::load_file(File.join(RAILS_ROOT, "config/god.yml"))
god_config = god_configs[Socket.gethostname.downcase.sub(/\..*$/, '')]
god_config = god_configs['default'] unless god_config

God.pid_file_directory = File.join(RAILS_ROOT, "tmp/pids")

def common(w)
  # applog(w, :debug, "PEDZ hello #{w.pid_file}")
  w.log = File.join(RAILS_ROOT, "log/#{w.name}.out")
  w.err_log = File.join(RAILS_ROOT, "log/#{w.name}.err")
  w.pid_file = w.pid_file
  w.dir = RAILS_ROOT
  w.start_grace = 10.seconds
  w.restart_grace = 10.seconds
  w.behavior(:clean_pid_file)
end

$beanstalkd = nil

God.watch do |w|
  w.name = "beanstalkd-raptor"
  common(w)
  $beanstalkd = w
  w.interval = 5.minutes
  w.group = 'beanstalk'
  if true                       # this is working
    w.start = "/usr/local/bin/beanstalkd & echo $! > #{w.pid_file}"
  else                          # this (double fork) hangs
    w.pid_file = nil
    w.start = "/usr/local/bin/beanstalkd"
  end
  w.stop = "kill -INT $( cat #{w.pid_file})"

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 1.minute
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

eval(god_config['ports']).each do |port|
  God.watch do |w|
    w.name = "raptor-thin-#{port}"
    common(w)
    w.group = 'raptor'
    w.interval = 1.minute
    w.start = "script/rvm-wrapper thin --daemonize --port #{port} \
      --environment #{god_config['environment']} --prefix /raptor --log #{w.log} \
      --pid #{w.pid_file} --chdir #{w.dir} start"
    w.stop = "script/rvm-wrapper thin --pid #{w.pid_file} stop"
    w.restart = "script/rvm-wrapper thin --pid #{w.pid_file} stop"

    w.start_if do |start|
      start.condition(:complex) do |c|
        c.interval = 1.minute
        c.this(:process_running) do |p|
          p.running = false
        end
        c.and(:process_running) do |p|
          p.pid_file = $beanstalkd.pid_file
          p.running = true
        end
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

(0 ... god_config['workers']).each do |worker|
  God.watch do |w|
    w.name = "raptor-worker-#{worker}"
    common(w)
    w.group = 'raptor'
    w.interval = 1.minute
    w.start = "script/rvm-wrapper vendor/plugins/async_observer/bin/worker \
      -d --pid #{w.pid_file} -e #{god_config['environment']}"
    w.stop = "kill -INT $( cat #{w.pid_file} )"

    w.start_if do |start|
      start.condition(:complex) do |c|
        c.interval = 1.minute
        c.this(:process_running) do |p|
          p.running = false
        end
        c.and(:process_running) do |p|
          p.pid_file = $beanstalkd.pid_file
          p.running = true
        end
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
