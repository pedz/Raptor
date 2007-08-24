
require 'singleton'

module Retain
  class Logon
    include Singleton

    def set(params)
      @params = params
    end

    def host
      @params.host
    end

    def port
      @params.port
    end

    def signon
      @params.signon
    end

    def password
      @params.password
    end
  end
end
