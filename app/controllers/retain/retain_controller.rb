module Retain
  class RetainController < ApplicationController

    before_filter :validate_retuser

    private
    
    def validate_retuser
      logger.debug("DEBUG: in validate_retuser")
      u = session[:user]

      # Avoid extra db hits if session[:retain] already set
      if params = session[:retain]
        logger.debug("DEBUG: setting logon params #{__LINE__}")
        Logon.instance.set(params)
        return true
      end

      # If no retusers defined for this user, then redirect and
      # set up a retain user.
      if u.retusers.empty?
        session[:original_uri] = request.request_uri
        redirect_to new_retuser_url
        return false
      end

      # Pull together the signon/password and the host/port and create
      # a ConnectionParamters structure.  We hold this in the session
      # data.  We also set the Logon instance to use these settings.
      ru = u.retusers[0]
      c = Retain::Config.symbolize_keys[RetainConfig::Node][0].symbolize_keys
      params = ConnectionParameters.new(:host => c[:host],
                                        :port => c[:port],
                                        :signon => ru.retid,
                                        :password => ru.password)
      session[:retain] = params
      logger.debug("DEBUG: setting logon params #{__LINE__}")
      Logon.instance.set(params)
      return true
    end
  end
end
