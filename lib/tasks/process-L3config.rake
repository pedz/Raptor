#
# A rake task that will read in and process the L3config.chain file
# that is stored in the tools directory.  This file comes from
# /gsa/ausgsa/projects/r/ratran/bin/misc and is maintained by Cindy
# Barrett.  It is (should be) unaltered.
#
# The file at the current time has some info at the top which is
# ignored.  Then it has a line that starts in the 1st column and
# specifies th column names.  The left column for each column is noted
# and that column is used to define the contents of the data below
# it.  i.e. I key off of the header line as to where the columns
# should start.  I assume the file is in 8859-1.

Column = Struct.new(:name, :column)

def extract_column(line, column_index)
end


desc "Load L3config.chain file"
task :l3config do
  Rake::Task["rake:environment"].invoke
  top = Rails.root
  columns = []
  column_names = { }
  File.open(top + "tools/L3config.chain") do |f|
    looking_for_header = true
    f.each_line do |l|
      l.chomp!
      if looking_for_header
        if l.length < 1 || l[0] == ' ' || l[0] == "\t"
          puts "Skipping: #{l}"
          next
        end
        looking_for_header = false
        l << ' '                # make sure at least one space at end
        state = :one
        column_name = ""
        column_start = -1
        (0 ... l.length).each do |i|
          case state
          when :one             # looking for start of a new column
            if l[i] != ' '
              column_name << l[i]
              column_start = i
              state = :two
            end
          when :two             # in a column name
            if l[i] == ' '
              column_names[column_name] = columns.length
              columns << Column.new(column_name, column_start)
              column_name = ""
              state = :one
            else
              column_name << l[i]
            end
          end
        end
        next
      end
      next if l[0] == '-' || l.length < 1       # skip the line of dashes
      # The columns I care about are:
      # "RETAIN_ID"
      # "Q"
      # "LOC"
      # "INTRANET_ID"
      retain_id   = l[columns[column_names["RETAIN_ID"]].column ...
                      (columns[column_names["RETAIN_ID"] + 1].column - 1)].strip
      q           = l[columns[column_names["Q"]].column ...
                      (columns[column_names["Q"] + 1].column - 1)].strip
      loc         = l[columns[column_names["LOC"]].column ...
                      (columns[column_names["LOC"] + 1].column - 1)].strip
      intranet_id = l[columns[column_names["INTRANET_ID"]].column ...
                      (columns[column_names["INTRANET_ID"] + 1].column - 1)].strip
      next if intranet_id.blank? || retain_id.blank? || q.blank? ||loc.blank?
      user = User.find_or_create_by_ldap_id(intranet_id)
      puts "User id is #{user.id}"
      retuser = user.retusers.find_or_create_by_retid_and_apptest(retain_id, false)
      puts "Retuser id is #{retuser.id}"

      registration = Cached::Registration.find_or_create_by_signon(retain_id)
      puts "Registration id is #{registration.id}"

      center = Cached::Center.find_or_create_by_center(loc)
      puts "Center id is #{center.id}"
      queue = center.queues.find_or_create_by_queue_name_and_h_or_s(q, 'S')
      puts "Queue id is #{queue.id}"
      
      # If queue and owner is already hooked up
      next if !queue.owners.empty? && queue.owners[0].id == registration.id

      # if queue already has an owner, then complain
      unless queue.owners.empty? && queue
        puts "Queue #{q},#{loc} already has an owner of #{queue.owners[0].signon}"
        next
      end
      # if registration already has a queue, then complain
      unless registration.queues.empty?
        puts "Retain id #{retain_id} already has a personal queue of #{registration.queues[0].queue_name},#{registration.queues[0].center.center}"
        next
      end
      
      Cached::QueueInfo.create(:queue => queue, :owner => registration)
    end
  end
end
