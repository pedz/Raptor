class LdapDept < ActiveLdap::Base
  ldap_mapping(:dn_attribute => 'dept',
               :prefix => 'ou=bluepages,o=ibm.com',
               :classes => ['ibmDepartment'])
  has_many :members, :class => 'LdapUser', :foreign_key => 'dept', :primary_key => 'dept'

  private

  def to_real_attribute_name(name, allow_normalized_name=nil)
    allow_normalized_name = true if allow_normalized_name.nil?
    super(name, allow_normalized_name)
  end
end
