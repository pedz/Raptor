#
# This is a class which should fetch entries from bluepages.  Many
# things need to be finalized because I do not know much about LDAP.
# But, that will happen over time.
#
class LdapUser < ActiveLdap::Base
  ldap_mapping :prefix => 'ou=bluepages', :dn_attribute => 'uid'
  belongs_to :manager, :class => 'LdapUser', :foreign_key => 'manager', :primary_key => 'dn'

  def self.authenticate_from_email(email, password)
    return nil unless (u = find(:attribute => "mail", :value => email))
    begin
      u.connection.rebind(:allow_anonymous => false, :password => password, :bind_dn => u.dn)
    rescue
      nil
    end
  end
end
