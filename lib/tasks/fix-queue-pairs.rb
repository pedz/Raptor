# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

#!/usr/bin/env ruby
#
# This can not be run by ruby but is run by doing:
#
# script/runner lib/tasks/fix-queue-pairs.rb
#
# Uses the file tools/queue-pairs as input
#

File.new("tools/queue-pairs").each do |line|
  line.chomp!
  retid, queue = line.split(' ')
  queue_name, center = queue.split(',')
  # This is broken now.  apptest needs to be set some how... I left it
  # alone for now because it isn't used
  next unless r = Cached::Registration.find_by_signon(retid)
  next unless c = Cached::Center.find_by_center(center)
  next unless q = c.queues.find_by_queue_name(queue_name)
  hq = Cached::QueueInfo.find_by_owner_id(r)
  qi = Cached::QueueInfo.find_by_queue_id_and_owner_id(q, r)
  if qi.nil?
    if hq.nil?
      Cached::QueueInfo.create(:queue => q, :owner => r)
    else
      temp = hq.queue
      puts "#{retid} (#{r.name}) already has personal queue of #{temp.queue_name},#{temp.center.center}"
    end
  end
end
