class QmController < ApplicationController
  HashEntry = Struct.new(:row_index, :col_index)
  QM_LAST_ROW_INDEX = 8

  def index
    @rotation_groups = RotationGroup.all(:select => :queue_id, :group => :queue_id)
  end

  def show
    @queue_name = params[:id]
    queue = Cached::Queue.find_by_param(@queue_name)
    if queue.nil?
      flash[:error] = "#{@queue_name} not found"
      redirect_to(qm_index_path)
      return
    end
    @rotation_groups = application_user.rotation_groups_for_queue(queue, :order => :name).map do |group|
      members = group.active_group_members(:include => :user)

      active_member_hash = {}
      # Create a two dimensional array with entries filled with new
      # RotationAssignment elements
      assignments = (0 .. QM_LAST_ROW_INDEX).map do |_notused|
        members.map do |member|
          group.rotation_assignments.build(:rotation_group => group,
                                           :assigned_to => member.user.id,
                                           :assigned_by => application_user.id)
        end
      end
      list = group.rotation_assignments.all(:order => 'created_at DESC')
      last_assigned_to = list[0] && list[0].assigned_to
      row_index = QM_LAST_ROW_INDEX
      members.each_with_index do |member, col_index|
        user_id = member.user_id
        active_member_hash[user_id] = HashEntry.new(row_index, col_index)
        # When we get to the user for which the last assignment was
        # given to, we make the subsequence member entries stop a row
        # above.
        if user_id == last_assigned_to
          row_index -= 1
        end
      end
      members_left = members.size
      list.each do |assignment|
        hash_entry = active_member_hash[assignment.assigned_to]
        # A rotation assignment might be for an inactive user in which
        # case they will not be in the active_member_hash
        if hash_entry
          if hash_entry.row_index == 0
            members_left -= 1
            if members_left <= 0
              break
            else
              next
            end
          end
          hash_entry.row_index -= 1
          assignments[hash_entry.row_index][hash_entry.col_index] = assignment
        end
      end
      {
        :group => group,
        :members => members,
        :assignments => assignments
      }
    end
  end
end
