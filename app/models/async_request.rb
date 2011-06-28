# -*- coding: utf-8 -*-
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
    tube = opts.fetch(:tube, (AsyncObserver::Queue.app_version or
                              AsyncObserver::Queue.default_tube))

    Rails.logger.debug("Worker: Sending async request: pri=#{pri}, class=#{@obj_class}, id=#{@obj_id}}")
    AsyncObserver::Queue.put!(self, pri, delay, ttr, tube)
  end

  def perform
    retuser = Retuser.find(@retuser_id)
    begin
      rec = @obj_class.constantize.find(@obj_id)
      @retain_user_connection_parameters = Retain::ConnectionParameters.new(retuser)
      Retain::Logon.instance.set(@retain_user_connection_parameters)
      cmb = rec.to_combined
      cmb.load_if_stale

    rescue ActiveRecord::RecordNotFound
      Rails.logger.debug "Worker: #{@obj_class} #{@obj_id} not found in database"
      return

    rescue Combined::CallNotFound, Combined::CenterNotFound,
      Combined::PmrNotFound, Combined::QueueNotFound => exception
      Rails.logger.error "Worker: #{@obj_class}:#{@obj_id} not found in Retain"
      return
      
    rescue Retain::FailedMarkedTrue
      # user record already marked so just return.
      return

    rescue Retain::LogonFailed => exception
      # Mark user record to prevent excessive errors.
      retuser.failed = true
      retuser.logon_return = exception.logon_return
      retuser.logon_reason = exception.logon_reason
      retuser.save
      return

    rescue Retain::SdiReaderError
      Rails.logger.error "Worker: SDI Reader error while processing #{@obj_class}:#{@obj_id}"
      return

    rescue Retain::RetainLogonEmpty
      Rails.logger.error "Worker: Retain Logon Empty error while processing #{@obj_class}:#{@obj_id}"
      return

    rescue Retain::RetainLogonShort
      Rails.logger.error "Worker: Retain Logon Short error while processing #{@obj_class}:#{@obj_id}"
      return

    rescue Retain::SdiDidNotReadField
      Rails.logger.error "Worker: SDI did not read field error while processing #{@obj_class}:#{@obj_id}"
      return

    rescue Errno::ECONNREFUSED
      # Our punch throughs must be broken but we have no one to talk
      # to.  Be a good time to email someone.
      Rails.logger.error "Worker: ECONNREFUSED to Retain -- check the punch throughs!"
      return

    rescue Exception => exception
      Rails.logger.error "Worker: Unexpected exception #{exception.message}:#{exception.backtrace}"
      return
    end
  end
end
