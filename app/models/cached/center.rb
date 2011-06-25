# -*- coding: utf-8 -*-

module Cached
  class Center < Base
    set_table_name "cached_centers"

    has_many :customers,        :class_name => "Cached::Customer"
    has_many :queues,           :class_name => "Cached::Queue"
    has_many :next_center_pmrs, :class_name => "Cached::Pmr", :foreign_key => "next_center_id"
    has_many :psars,            :class_name => "Cached::Psar"
    has_many(:software_registrations,
             :class_name => "Cached::Registration",
             :foreign_key => "software_center_id",
             :order => "name")
    has_many(:hardware_registrations,
             :class_name => "Cached::Registration",
             :foreign_key => "hardware_center_id",
             :order => "name")
    
    def registrations
      software_registrations + hardware_registrations
    end
  end
end
