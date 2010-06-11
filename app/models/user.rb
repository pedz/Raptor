# -*- coding: utf-8 -*-

class User < ActiveRecord::Base
  attr_protected :ldap_id, :retain_user_id, :admin
  has_many :retusers
  has_many :favorite_queues, :class_name => "Cached::FavoriteQueue", :include => :queue

  # retuser as oppose to retusers returns the retuser from retusers
  # whose test flag matches the current value of test in the user
  # model.
  def retuser
    retusers.find(:first, :conditions => { :test_mode => test_mode })
  end
  
  def ldap
    LdapUser::find(:attribute => 'mail', :value => ldap_id)
  end

  def first_name
    @first_name ||= 
      if (given = ldap.givenName).is_a? Array
        given.min { |a, b| a.length <=> b.length }
      else
        given
      end
  end
end
