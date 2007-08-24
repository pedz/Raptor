module Retain
  class RetainController < ApplicationController

    before_filter :validate_retain_user

    private
    
    def validate_retain_user
      u = session[:user]

      # Avoid extra db hits if session[:retain] already set
      if param = session[:retain]
        Logon.instance.set(params)
        return true
      end

      # If no retain_users defined for this user, then redirect and
      # set up a retain user.
      if u.retain_users.empty?
        session[:original_uri] = request.request_uri
        redirect_to new_retain_user_url
        return false
      end

      # Pull together the signon/password and the host/port and create
      # a ConnectionParamters structure.  We hold this in the session
      # data.  We also set the Logon instance to use these settings.
      ru = u.retain_users[0]
      c = Retain::Config.symbolize_keys[RetainConfig::Node][0].symbolize_keys
      params = ConnectionParameters.new(:host => c[:host],
                                        :port => c[:port],
                                        :signon => ru.retid,
                                        :password => ru.password)
      session[:retain] = params
      Logon.instance.set(params)
      return true
    end
  end
end
