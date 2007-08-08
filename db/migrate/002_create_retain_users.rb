# The retain user record.  Presently has only the id and password but
# may grow to have other fields.
#
# +retid+::    +string+ -- retain id
# +password+:: +string+ -- retain password
#
class CreateRetainUsers < ActiveRecord::Migration
  def self.up
    create_table :retain_users do |t|
      t.string :retid, :null => false
      t.string :password, :null => false
      t.timestamps 
    end
  end

  def self.down
    drop_table :retain_users
  end
end
