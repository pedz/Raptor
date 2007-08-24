# The retain user record.  Presently has only the id and password but
# may grow to have other fields.
#
# +retid+::    +string+ -- retain id
# +password+:: +string+ -- retain password
#
class CreateRetusers < ActiveRecord::Migration
  def self.up
    create_table :retusers do |t|
      t.integer :user_id
      t.string  :retid, :null => false
      t.string  :password, :null => false
      t.timestamps 
    end
  end

  def self.down
    drop_table :retusers
  end
end
