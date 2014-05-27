class QmController < ApplicationController
  def index
    @rotation_groups = RotationGroup.all(:select => :queue_id, :group => :queue_id)
  end

  def show
    # Cheating here a bit ... just use the queue's name to find the queue (and not the center)
    @queue_name = params[:id]
    queue = Cached::Queue.find_by_queue_name(@queue_name.split(',')[0])
    @rotation_groups = queue.rotation_groups.map do |group|
      members = group.rotation_group_members.all(:order => :name)

      # We go backwards through the assignments until we hit the 4th
      # entry for someone.  This will give us 3 rows back.  While we
      # do this, we push each assignment unto a queue for that
      # particular person.
      member_hash = {}
      assignments = (0 .. 3).map do |index|
        members.map do |member|
          group.rotation_assignments.build(:rotation_group => group,
                                           :assigned_to => member.user.id,
                                           :assigned_by => application_user.id)
        end
      end
      members.each_with_index do |member, index|
        member_hash[member.user_id] = {
          :index => index,
          :count => 3
        }
      end
      group.rotation_assignments.all(:order => :created_at).reverse.each do |assignment|
        h = member_hash[assignment.assigned_to]
        break if h[:count] == 0
        h[:count] -= 1
        logger.debug "Adding #{assignment.id} to #{h[:count]} and #{h[:index]}"
        assignments[h[:count]][h[:index]] = assignment
      end
      logger.debug assignments.inspect
      
      # rows = []
      # Now, we create an array of rows -- up to three rows with
      # assignments plus an extra blank row.

      {
        :group => group,
        :members => members,
        :assignments => assignments
      }
    end
  end
end
