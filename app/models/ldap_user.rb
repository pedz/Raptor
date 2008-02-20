#
# This is a class which should fetch entries from bluepages.  Many
# things need to be finalized because I do not know much about LDAP.
# But, that will happen over time.
#
class LdapUser < ActiveLdap::Base
  ldap_mapping :prefix => 'ou=bluepages', :dn_attribute => 'uid'
  belongs_to :manager, :class => 'LdapUser', :foreign_key => 'manager', :primary_key => 'dn'
  has_many   :manages, :class => 'LdapUser', :foreign_key => 'dn', :primary_key => 'manager'

  def self.authenticate_from_email(email, password)
    return nil unless (u = find(:attribute => "mail", :value => email))
    begin
      dn = u.dn.gsub(/\+/, "\\\\+")
      logger.debug("authenticate_from_email #{email} => #{dn}")
      u.connection.rebind(:allow_anonymous => false, :password => password, :bind_dn => dn)
    rescue
      logger.debug("authenticate_from_email denied")
      nil
    end
  end
end
