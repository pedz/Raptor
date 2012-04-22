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
  STDERR.puts "Dumping ArgumentTypes" if STDERR.isatty
  puts ArgumentType.all(:order => :name).to_json(:except => :id)
  
  # NameType has an external reference to ArgumentType which can be
  # made via the name or the posisition.  I'll use name
  STDERR.puts "Dumping NameTypes" if STDERR.isatty
  puts NameType.all(:order => :name).to_json(:except => [:id, :argument_type_id ],
                                             :include => { :argument_type => { :only => :name }})

  # Name has two external references but the reference to the NameType
  # is by the name itself and not by the id so it does not need any
  # extra work.  The owner however, does.  This will become the rule
  # for most of the other types.
  STDERR.puts "Dumping Names" if STDERR.isatty
  puts Name.all(:order => :name).to_json(:except => [:id, :owner_id ], :include => { :owner => { :only => :ldap_id }})

  # ArgumentDefault has an external reference to a name
  STDERR.puts "Dumping ArgumentDefaults" if STDERR.isatty
  puts ArgumentDefault.all(:order => :argument_position).to_json(:except => [:id, :name_id ], :include => { :name => { :only => :name }})

  # AssociationType has only a name
  STDERR.puts "Dumping AssociationTypes" if STDERR.isatty
  puts AssociationType.all(:order => :association_type).to_json(:except => :id)

  # Condition has a name_id
  STDERR.puts "Dumping Conditions" if STDERR.isatty
  puts Condition.all(:include => :name, :order => "names.name").to_json(:except => [:id, :name_id ],
                                                                       :include => { :name => { :only => :name }})

  # Widget has an owner
  STDERR.puts "Dumping Widgets" if STDERR.isatty
  puts Widget.all(:order => :name).to_json(:except => [:id, :owner_id ], :include => { :owner => { :only => :ldap_id }})

  # Element has an owner, view, and widget.  owner will use ldap_id,
  # widget will use the name in the widget, view is actually a name
  # and will use the name
  STDERR.puts "Dumping Elements" if STDERR.isatty
  puts Element.all(:include => :view, :order => "names.name, elements.row, elements.col").to_json(:except=> [:id, :owner_id, :widget_id, :view_id ],
                                                                                    :include => {
                                                                                      :owner => { :only => :ldap_id},
                                                                                      :widget => { :only => :name },
                                                                                      :view => { :only => :name}})
  
  # RelationshipType has
  #   1) container_type which is actually a name_type so will use the name_type's name,
  #   2) association_type which will use the association's association (I hate that name).
  #   3) item_type which is also a name_type so will use the name_type's name.
  STDERR.puts "Dumping RelationshipTypes" if STDERR.isatty
  puts RelationshipType.all(:include => [ :container_type, :association_type, :item_type],
                            :order => "name_types.name, association_types.association_type, item_types_relationship_types.name").
    to_json(:except => [:id, :container_type_id, :association_type_id, :item_type_id ],
            :include => {
              :container_type => { :only => :name},
              :association_type => { :only => :association_type },
              :item_type => { :only => :name }})

  # Relationship is the bitch of them all.  It has
  #   1) container_name which is a name so will use the name's name
  #   2) relationship_type which needs to use the triple of the
  #      container's name, the association's association, and the
  #      item_type's name.
  #   3) The item which is polymorphic so will record the type and use
  #      the method item_name (already defiend for each type of
  #      element that can be contained) to get the unique name for the
  #      item.
  STDERR.puts "Dumping Relationships" if STDERR.isatty
  puts Relationship.all.to_json(:except => [:id, :container_name_id, :relationship_type_id, :item_id ],
                                :include => {
                                  :container_name => { :only => :name },
                                  :relationship_type => {
                                    :except => [:id, :container_type_id, :association_type_id, :item_type_id ],
                                    :include => { 
                                      :container_type => { :only => :name},
                                      :association_type => { :only => :association_type },
                                      :item_type => { :only => :name}}},
                                  :item => {
                                    :only => [ ],
                                    :methods => :item_name
                                  }})
end

task :restore_items do
  Rake::Task["rake:environment"].invoke

  # Finds the Name and fixes name_id
  def fix_name(o)
    name_name = o.delete("name")["name"]
    n = Name.find_by_name(name_name)
    o['name_id'] = n.id
  end

  def fix_owner(o)
    owner_name = o.delete("owner")["ldap_id"]
    u = User.find_or_create_by_ldap_id(owner_name)
    o['owner_id'] = u.id
  end

  require 'argument_type'
  class ArgumentType < ActiveRecord::Base
    # ArgumentType has no external references that need to get resolved.
    def import(o)
      update_attributes(o)
    end
  end

  require 'name_type'
  class NameType < ActiveRecord::Base
    # NameType has no external references that need to get resolved.
    def import(o)
      argument_type_name= o.delete("argument_type")["name"]
      a = ArgumentType.find_by_name(argument_type_name)
      o['argument_type_id'] = a.id
      update_attributes(o)
    end
  end

  require 'name'
  class Name < ActiveRecord::Base
    # NameType has no external references that need to get resolved.
    def import(o)
      fix_owner(o)
      update_attributes(o)
    end
  end

  require 'argument_default'
  class ArgumentDefault < ActiveRecord::Base
    def import(o)
      fix_name(o)
      update_attributes(o)
    end
  end

  require 'association_type'
  class AssociationType < ActiveRecord::Base
    def import(o)
      update_attributes(o)
    end
  end

  require 'condition'
  class Condition < ActiveRecord::Base
    def import(o)
      fix_name(o)
      update_attributes(o)
    end
  end

  require 'widget'
  class Widget < ActiveRecord::Base
    def import(o)
      fix_owner(o)
      update_attributes(o)
    end
  end
  
  require 'element'
  class Element < ActiveRecord::Base
    def import(o)
      fix_owner(o)
      # Fix widget name
      widget_name = o.delete("widget")["name"]
      w = Widget.find_by_name(widget_name)
      o['widget_id'] = w.id
      # Fix view name
      view_name = o.delete("view")["name"]
      n = Name.find_by_name(view_name)
      o['view_id'] = n.id
      update_attributes(o)
    end
  end
  
  require 'relationship_type'
  class RelationshipType < ActiveRecord::Base
    def import(o)
      # Fix container_type
      container_type_name = o.delete("container_type")["name"]
      c = NameType.find_by_name(container_type_name)
      o['container_type_id'] = c.id
      # Fix assocation_type
      association_type_association_type = o.delete("association_type")["association_type"]
      a = AssociationType.find_by_association_type(association_type_association_type)
      o['association_type_id'] = a.id
      # Fix item_type
      item_type_name = o.delete("item_type")["name"]
      i = NameType.find_by_name(item_type_name)
      o['item_type_id'] = i.id
      update_attributes(o)
    end
  end
  
  require 'relationship'
  class Relationship < ActiveRecord::Base
    def import(o)
      # Fix container_name
      container_name_name = o.delete("container_name")["name"]
      c = Name.find_by_name(container_name_name)
      o['container_name_id'] = c.id

      # Fix relationship_type
      relationship_type = o.delete("relationship_type")
      container_type = relationship_type['container_type']
      association_type = relationship_type['association_type']
      item_type = relationship_type['item_type']
      r = RelationshipType.find(:first,
                                :include => [ :container_type, :association_type, :item_type ],
                                :conditions => {
                                  "name_types.name" => container_type['name'],
                                  "association_types.association_type" => association_type['association_type'],
                                  "item_types_relationship_types.name" => item_type['name']
                                })
      o['relationship_type_id'] = r.id

      # Fix item_id and item_type
      item = o.delete("item")
      c = o['item_type'].camelize.constantize
      i = c.find_by_item_name(item['item_name'])
      o['item_id'] = i.id

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
