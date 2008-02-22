# The users table is the top level table describing a user.  Different
# user type records hang off of it such as a record for the users ldap
# entry (bluepages), the users retain entry, etc.
#
# +ldap_id+::        +string+  -- Bluepages mail address
# +retain_user_id+:: +integer+ -- id to the retain record
# +admin+::          +boolean+ -- User can administor this site
#
class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string     :ldap_id, :null => false
      t.boolean    :admin, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
