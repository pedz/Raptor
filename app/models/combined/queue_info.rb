module Combined
  class QueueInfo < Base
    set_expire_time :never

    def to_param
      @cached.id.to_s
    end
    
    # Need to define this even though it doesn't do anything
    def load
    end
  end
end
