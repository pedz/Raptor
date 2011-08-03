# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
#
# Feed this a file of tree looking (nested) entries and it will create
# them...

Owner = User.find_by_ldap_id('pedzan@us.ibm.com')
LeadingSpaces = Regexp.new('(^ *)([^ ].*)')

def process_line(line, parent)
  line = LeadingSpaces.match(line)[2]
  name, real_type, association_type = line.split(' - ')
  entity = Entity.find(:first, :conditions => { :name => name, :real_type => real_type })
  if entity.nil?
    puts "Creating '#{name}' of class '#{real_type}'"
    klass = real_type.constantize
    case real_type
    when 'User'
      temp = klass.new
      temp.ldap_id = name
      temp.save
    else
      temp = klass.create(:name => name, :owner => Owner)
    end
    entity = Entity.find(:first, :conditions => { :name => name, :real_type => real_type })    
  else
    puts "Found #{name}"
  end
  item = entity.item
  item_type = entity.name_type

  unless association_type.nil?
    item_type_id = item_type.id
    container_type_id = parent.name_type.id
    at = AssociationType.find_by_association_type(association_type)
    if at.nil?
      raise "Unknown Association Type #{association_type}"
    end
    rt = RelationshipType.find(:first, :conditions => {
                                 :container_type_id => container_type_id,
                                 :association_type_id => at.id,
                                 :item_type_id => item_type_id
                               })
    if rt.nil?
      raise "Relationship Type for #{parent.item_name} #{association_type} #{item.item_name}"
    end
    rt_options = {
      :container_name_id => parent.id,
      :relationship_type_id => rt.id,
      :item_id => item.id,
      :item_type => entity.base_type
    }
    rt = Relationship.find(:first, :conditions => rt_options)
    if rt.nil?
      puts "Creating new relationship #{parent.item_name} #{association_type} #{item.item_name}"
      rt = Relationship.create(rt_options)
    else
      puts "Relationship #{parent.item_name} #{association_type} #{item.item_name} already exists"
    end
  end
  return item
end

def get_next_line(file)
  begin
    l = file.readline.chomp while l.blank?
  rescue EOFError
    return nil
  end
  return l
end

def process_file(file, line, parent)
  # First determine out level of indent
  indent = LeadingSpaces.match(line)[1].length
  item = process_line(line, parent)
  line = get_next_line(file)
  until line.nil?
    new_indent = LeadingSpaces.match(line)[1].length
    break if new_indent < indent

    if new_indent > indent
      line = process_file(file, line, item)
    else
      item = process_line(line, parent)
      line = get_next_line(file)
    end
  end
  return line
end

if __FILE__ == $0 || $0 == 'script/runner'
  Entity.transaction do 
    begin
      line = get_next_line($<)
      while (line)
        line = process_file($<, line, nil)
      end
      puts "All done!"
    rescue Exception => e
      puts "At line #{$<.lineno}"
      puts e.message
      puts e.backtrace
      raise ActiveRecord::Rollback
    end
  end
end
