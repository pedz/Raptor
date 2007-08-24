# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  before_filter :authenticate

  def admin?
    session[:user].admin
  end

  private
  #
  # A before_filter for the entire application.  This authenticates
  # against bluepages.  If authentication succeeds, the matching user
  # record is found.  If it does not exist, it is created and
  # initialized with the ldap_id field.  The user model is stored in
  # the session.
  #
  def authenticate
    return true if session[:user]
    ActiveLdap::Base.establish_connection
    authenticate_or_request_with_http_basic "Raptor" do |user_name, password|
      next nil unless LdapUser.authenticate_from_email(user_name, password)
      u = User.find_by_ldap_id(user_name)
      if u.nil?
        # Can not use this because ldap_id is protected
        # User.create!(:ldap_id => user_name)
        # Use this instead:
        u = User.new
        u.ldap_id = user_name
        u.save!
      end
      session[:user] = u
      session[:retain] = nil
      return true
    end
  end
end
