# -*- coding: utf-8 -*-
#
# A rake task that will read in and process the L3config.chain file
# that is stored in the tools directory.  This file comes from
# /gsa/ausgsa/projects/r/ratran/bin/misc and is maintained by Cindy
# Barrett.  It is (should be) unaltered.
#
# The file at the current time has some info at the top which is
# ignored.  Then it has a line that names the columns.  The line after
# this is a line with only spaces and dashes.  The space dash line is
# what we key off of.  The left column for each column is noted and
# that column is used to define the contents of the data below it.
# i.e. I key off of the header line as to where the columns should
# start.  I assume the file is in 8859-1.

Column = Struct.new(:name, :column)

def extract_column(line, column_index)
end


desc "Load L3config.chain file"
task :l3config do
  Rake::Task["rake:environment"].invoke
  top = Rails.root
  columns = []
  column_names = { }
  header_line = ""
  File.open(top + "tools/L3config.chain") do |f|
    looking_for_header = true
    last_line = ""
    f.each_line do |l|
      l.chomp!
      next if l.length < 4      # empty and stubby lines are ignored.
      if looking_for_header
        # Find the line with dashes
        unless /^[- ]*$/.match(l)
          header_line = l
          puts "Skipping: #{l}"
          next
        end
        looking_for_header = false
        header_line << ' '                # make sure at least one space at end
        state = :one
        column_name = ""
        column_start = -1
        (0 ... header_line.length).each do |i|
          case state
          when :one             # looking for start of a new column
            if header_line[i] != ' '
              column_name << header_line[i]
              column_start = i
              state = :two
            end
          when :two             # in a column name
            if header_line[i] == ' '
              column_names[column_name] = columns.length
              columns << Column.new(column_name, column_start)
              column_name = ""
              state = :one
            else
              column_name << header_line[i]
            end
          end
        end
        puts column_names.inspect
        next
      end
      # The columns I care about are:
      # "RETAIN_ID"
      # "Q"
      # "LOC"
      # "QTYPE"
      # "INTRANET_ID"
      retain_id   = l[columns[column_names["RETAIN_ID"]].column ...
                      (columns[column_names["RETAIN_ID"] + 1].column - 1)].strip

      q           = l[columns[column_names["Q"]].column ...
                      (columns[column_names["Q"] + 1].column - 1)].strip

      loc         = l[columns[column_names["LOC"]].column ...
                      (columns[column_names["LOC"] + 1].column - 1)].strip

      intranet_id = l[columns[column_names["INTRANET_ID"]].column ...
                      (columns[column_names["INTRANET_ID"] + 1].column - 1)].strip.downcase

      queue_type  = l[columns[column_names["QTYPE"]].column ...
                      (columns[column_names["QTYPE"] + 1].column - 1)].strip

      next if intranet_id.blank? || retain_id.blank? || q.blank? ||loc.blank? || queue_type != "PERSONAL"
      # user = User.find_by_ldap_id(intranet_id) || User.create(:ldap_id => intranet_id)
      # puts intranet_id
      user = User.find_or_create_by_ldap_id(intranet_id)
      # puts "User id is #{user.id}"
      retuser = user.retusers.find_by_retid_and_apptest(retain_id, false)
      if retuser.nil?
        retuser = user.retusers.create :retid => retain_id, :apptest => false, :password => 'xxxxxxxx'
      end
      # puts "Retuser id is #{retuser.id}"

      registration = Cached::Registration.find_or_create_by_signon(retain_id)
      # puts "Registration id is #{registration.id}"

      center = Cached::Center.find_or_create_by_center(loc)
      # puts "Center id is #{center.id}"
      queue = (center.queues.find(:first, :conditions => { :queue_name => q, :h_or_s => 'S'}) ||
               center.queues.create(:queue_name => q, :h_or_s => 'S'))
      # puts "Queue id is #{queue.id}"
      
      if queue.owners.length > 1
        puts "#{queue.queue_name} has more than one owner.  Clearing all of them."
        queue.queue_infos.clear
      end

      # If queue and owner is already hooked up
      next if !queue.owners.empty? && queue.owners[0].id == registration.id

      # if queue already has an owner, then complain
      unless queue.owners.empty? && queue
        puts "Queue #{q},#{loc} already has an owner of #{queue.owners[0].signon}"
        next
      end
      # if registration already has a queue, then complain
      unless registration.queues.empty?
        puts "Retain id #{retain_id} Queue #{q},#{loc} already has a personal queue of #{registration.queues[0].queue_name},#{registration.queues[0].center.center} -- replacing..."
        registration.queues[0].delete
      end
      
      Cached::QueueInfo.create(:queue => queue, :owner => registration)
    end
  end
end
