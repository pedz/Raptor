# -*- coding: utf-8 -*-

class User < ActiveRecord::Base
  attr_protected :ldap_id, :retain_user_id, :admin
  has_many :retusers, :include => [ :software_node, :hardware_node ]
  has_many :favorite_queues, :class_name => "Cached::FavoriteQueue", :include => :queue
  belongs_to :current_retain_id, :class_name => "Retuser", :foreign_key => "current_retuser_id"

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
