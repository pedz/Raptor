class RetainController < ApplicationController

  before_filter :validate_retain_user

  private
  
  def validate_retain_user
    u = session[:user]
    return true if u.retain_user
    session[:original_uri] = request.request_uri
    redirect_to :controller => "/retain_users", :action => "new"
  end
end
