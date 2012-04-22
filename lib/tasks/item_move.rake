# -*- coding: utf-8 -*-

desc "Task to dump items, groups, etc to a file"
task :dump_items do
  Rake::Task["rake:environment"].invoke
  # Need to smash the ar_objects gunk -- just not needed.
  class ActiveRecord::Base
    def ar_objects
      nil
    end
  end
  puts ArgumentType.all.to_json(:except => :id)
  
  # NameType has an external reference to ArgumentType which can be
  # made via the name or the posisition.  I'll use name
  puts NameType.all.to_json(:except => :id, :include => { :argument_type => { :only => :name }})

  # Name has two external references but the reference to the NameType
  # is by the name itself and not by the id so it does not need any
  # extra work.  The owner however, does.  This will become the rule
  # for most of the other types.
  puts Name.all.to_json(:except => :id, :include => { :owner => { :only => :ldap_id }})

  # ArgumentDefault has an external reference to a name
  puts ArgumentDefault.all.to_json(:except => :id, :include => { :name => { :only => :name }})
end

task :restore_items do
  Rake::Task["rake:environment"].invoke

  class ArgumentType < ActiveRecord::Base
    # ArgumentType has no external references that need to get resolved.
    def import(o)
      update_attributes(o)
    end
  end

  class NameType < ActiveRecord::Base
    # NameType has no external references that need to get resolved.
    def import(o)
      argument_type_name= o.delete("argument_type")["name"]
      a = ArgumentType.find_by_name(argument_type_name)
      o['argument_type_id'] = a.id
      update_attributes(o)
    end
  end

  class Name < ActiveRecord::Base
    # NameType has no external references that need to get resolved.
    def import(o)
      owner_name = o.delete("owner")["ldap_id"]
      u = User.find_or_create_by_ldap_id(owner_name)
      o['owner_id'] = u.id
      update_attributes(o)
    end
  end

  class ArgumentDefault < ActiveRecord::Base
    def import(o)
      name_name = o.delete("name")["name"]
      n = Name.find_by_name(name_name)
      o['name_id'] = n.id
      update_attributes(o)
    end
  end

  Relationship.destroy_all
  RelationshipType.destroy_all
  Element.destroy_all
  Widget.destroy_all
  Condition.destroy_all
  AssociationType.destroy_all
  ArgumentDefault.destroy_all
  Name.destroy_all
  NameType.destroy_all
  ArgumentType.destroy_all

  # "K2" needs to be passed in obviously
  IO.readlines("K2").each do |line|
    # Each line is an array of similar things.  With
    # ActiveRecord::Base.include_root_in_json set to true, the items
    # are wrapped.  We need this to tell us the type of each item.
    JSON.parse(line).each do |wrapper|
      # each "thing" is a hash with one key which denotes the type of
      # the item
      item_type = wrapper.keys[0]
      # dig out the real item
      item = wrapper[item_type]
      # need to delete the ar_objects
      item.delete "ar_objects"
      item_type.camelize.constantize.new.import(item)
    end
  end
end
