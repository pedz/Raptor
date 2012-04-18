# -*- coding: utf-8 -*-

desc "Task to dump items, groups, etc to a file"
task :dump_items do
  Rake::Task["rake:environment"].invoke
  # Can't decide how I want to do this...
  # ActiveRecord::Base.include_root_in_json = false

  # Need to smash the ar_objects gunk -- just not needed.
  class ActiveRecord::Base
    def ar_objects
      nil
    end
  end
  puts NameType.all.to_json(:except => :id)
end

task :restore_items do
  Rake::Task["rake:environment"].invoke
  class NameType < ActiveRecord::Base
    # NameType has not external references that need to get resolved.
    def self.import(o)
      n = NameType.new(o)
      puts n.inspect
    end
  end

  lines = IO.readlines("K2")
  a = JSON.parse(lines[0])
  b = a[0]                      # first object in array
  k = b.keys                    # list of keys in object -- should be just 1
  c = k[0]                      # the type e.g. name_type
  o = b[c]
  o.delete "ar_objects"
  case c
  when "name_type"
    NameType.import(o)
  end
end
