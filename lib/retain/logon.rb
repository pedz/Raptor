
require 'singleton'

module Retain
  class Logon
    include Singleton

    def set(params)
      @params = params
      @return_value = nil
      @reason = nil
    end

    def return_value=(value)
      @return_value = value
    end

    def reason=(value)
      @reason = value
    end

    def return_value
      @return_value
    end

    def reason
      @reason
    end

    def signon
      @params.signon
    end

    def password
      @params.password
    end

    def failed
      @params.failed
    end
  end
end
