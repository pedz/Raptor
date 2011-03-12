require 'async_observer/queue'

class << AsyncObserver::Queue
  def default_pri
    DEFAULT_PRI
  end

  def default_fuzz
    DEFAULT_FUZZ
  end

  def default_delay
    DEFAULT_DELAY
  end

  def default_ttr
    DEFAULT_TTR
  end

  def default_tube
    DEFAULT_TUBE
  end
end

class AsyncRequest
  def self.perform(job)
    # Note: job.ybody wasn't working for me.
    ar = YAML.load(job.body)    # The transmitted AsyncRequest
    ar.perform
    job.delete
    true
  end
  
  def initialize(id, obj)
    @retuser_id = id
    # @obj = obj
    @obj_class = obj.class.to_s
    @obj_id = obj.id
  end

  # Not using the one in AsyncObserver::Extensions because it is too
  # braindead.
  def async_send(action, opts = { })
    @type = :raptor
    pri = opts.fetch(:pri, AsyncObserver::Queue.default_pri)
    fuzz = opts.fetch(:fuzz, AsyncObserver::Queue.default_fuzz)
    delay = opts.fetch(:delay, AsyncObserver::Queue.default_delay)
    ttr = opts.fetch(:ttr, AsyncObserver::Queue.default_ttr)
    tube = opts.fetch(:tube, (AsyncObserver::Queue.app_version or AsyncObserver::Queue.default_tube))

    AsyncObserver::Queue.put!(self, pri, delay, ttr, tube)
  end

  def perform
    retuser = Retuser.find(@retuser_id)
    rec = @obj_class.constantize.find(@obj_id)
    @retain_user_connection_parameters = Retain::ConnectionParameters.new(retuser)
    Retain::Logon.instance.set(@retain_user_connection_parameters)
    cmb = rec.to_combined
    cmb.load_if_stale
  end
end
