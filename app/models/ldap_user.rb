# -*- coding: utf-8 -*-

#
# This is a class which should fetch entries from bluepages.  Many
# things need to be finalized because I do not know much about LDAP.
# But, that will happen over time.
#
class LdapUser < ActiveLdap::Base
  ldap_mapping(:dn_attribute => 'uid',
               :prefix => 'ou=bluepages',
               :classes => [ 'ibmPerson' ])

  belongs_to :mgr,     :class => 'LdapUser', :foreign_key => 'manager', :primary_key => 'dn'
  belongs_to :deptmnt, :class => 'LdapDept', :foreign_key => 'dept',    :primary_key => 'dept'
  has_many   :manages, :class => 'LdapUser', :foreign_key => 'manager', :primary_key => 'dn'

  def self.authenticate_from_email(email, password)
    return nil unless (u = find(:first, :attribute => 'mail', :value => email, :attributes => [ 'dn']))
    begin
      # dn = u.dn.to_s.gsub(/\+/, "\\\\+")
      dn = u.dn.to_s
      logger.info("authenticate_from_email #{email} => #{dn}")
      u.connection.rebind(:allow_anonymous => false, :password => password, :bind_dn => dn)
    rescue => e
      # logger.debug("authenticate_from_email denied #{e.class} #{e.message}")
      nil
    end
  end

  # def manages
  #   find(:all, :attribute => 'manager', :value => dn)
  # end

  def self.q
    find(:first, :attribute => 'mail', :value => 'pedzan@us.ibm.com')
  end

  private

  # def to_real_attribute_name(name, allow_normalized_name=nil)
  #   allow_normalized_name = true if allow_normalized_name.nil?
  #   super(name, allow_normalized_name)
  # end
end
