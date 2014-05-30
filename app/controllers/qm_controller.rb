class QmController < ApplicationController
  def index
    @rotation_groups = RotationGroup.all(:select => :queue_id, :group => :queue_id)
  end

  def show
    # Cheating here a bit ... just use the queue's name to find the queue (and not the center)
    @queue_name = params[:id]
    queue = Cached::Queue.find_by_queue_name(@queue_name.split(',')[0])
    @rotation_groups = queue.rotation_groups.map do |group|
      members = group.sorted_group_members

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
      list = group.sorted_assignments.reverse
      count = 3
      members.each_with_index do |member, index|
        user_id = member.user_id
        member_hash[user_id] = {
          :index => index,
          :count => count
        }
        if user_id == list[0].assigned_to
          count = 2
        end
      end
      members_left = members.size
#      last_assignment = false
      list.each do |assignment|
        h = member_hash[assignment.assigned_to]
        if h[:count] == 0
          members_left -= 1
          if members_left <= 0
            break
          else
            next
          end
        end
        h[:count] -= 1
        # unless last_assignment
        #   last_assignment = true
        #   row = h[:count]
        #   ((h[:index] + 1) .. members.size).each do |index|
        #     assignments[row][index] = assignments[row + 1][index]
        #     assignments[row + 1][index] = nil
        #   end
        # end
        assignments[h[:count]][h[:index]] = assignment
      end
      
      {
        :group => group,
        :members => members,
        :assignments => assignments
      }
    end
  end
end
