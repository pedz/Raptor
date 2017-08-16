class QmController < ApplicationController
  HashEntry = Struct.new(:row_index, :col_index)

  # This constant is vaguely connected with QM_FULL_ROWS_SHOWN in the
  # helper.  QM_LAST_ROW_INDEX needs to be large enough so that the
  # temporary table we build has enough rows to show
  # QM_FULL_ROWS_SHOWN rows plus the rows needed for the assignments
  # which can get spread out by a large amount sometimes.
  QM_LAST_ROW_INDEX = 12

  def index
    @rotation_groups = RotationGroup.all(:select => :queue_id, :group => :queue_id)
  end

  def show
    @queue_name = params[:id]
    queue = Cached::Queue.find_by_param(@queue_name)

    # if bogus queue, flash and error and return
    if queue.nil?
      flash[:error] = "#{@queue_name} not found"
      redirect_to(qm_index_path)
      return
    end

    # Find the rotation groups that this user belongs to and monitor the requested queue.
    # I'm going to leave this as a comment.  The line below restricts
    # the rotation groups to be the groups with the same queue for
    # this particular user.  This is what I had originally but
    # non-members (management) can't see the activity.  Of
    # course... that might be a good thing.
    # @rotation_groups = application_user.rotation_groups_for_queue(queue, :order => :name).map do |group|
    @rotation_groups = queue.rotation_groups.all(queue, :order => :name).map do |group|
      # active group members alphabetized by name
      members = group.active_group_members(:include => :user)

      # active_member_hash will have keys of user ids and values of HashEntry.
      active_member_hash = {}

      # Create a two dimensional array with entries filled with new
      # RotationAssignment elements.  Rows go from 0 up to
      # QM_LAST_ROW_INDEX.  Columns go
      assignments = (0 .. QM_LAST_ROW_INDEX).map do |_notused|
        members.map do |member|
          group.rotation_assignments.build(:rotation_group => group,
                                           :assigned_to => member.user.id,
                                           :assigned_by => application_user.id)
        end
      end

      # Gets rotation assignments for this group ordered backward
      # through time.
      list = group.rotation_assignments.all(:order => 'created_at DESC')

      # last assignment is list[0] (if any)
      last_assigned_to = list[0] && list[0].assigned_to

      # Going from left to right, the bottom row is filled in for the
      # members who appear before the member last assigned to.
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

      # We go through the list of assignments (backwards).  When we
      # find an assignment for a member, we decrement that member's
      # row index by one.  When all the members have reached row 0, we
      # stop.
      members_left = members.size
      list.each do |assignment|
        # find HashEntry for the member this assignment was given to.
        hash_entry = active_member_hash[assignment.assigned_to]

        # A rotation assignment might be for an inactive user in which
        # case they will not be in the active_member_hash
        if hash_entry

          # if this member has already filled all the rows, just move on
          next if hash_entry.row_index == -1

          # if this member has now filled up all the rows, adjust the
          # number of members left and break out if no members are left.
          if hash_entry.row_index == 0
            hash_entry.row_index -= 1
            members_left -= 1
            if members_left <= 0
              break
            else
              next
            end
          end

          # Decrement before the assignment to guarantee that the last
          # row for the member will be a new record.
          hash_entry.row_index -= 1

          # Now fill in the assignment into the table element
          assignments[hash_entry.row_index][hash_entry.col_index] = assignment
        end
      end

      # We want only one new record form per member.  In the case that
      # things get out of sync, this step walks up each column and
      # sets the rotation type to "no-op".  The form layout code sees
      # this and puts a form for a new record only if the rotation
      # type is also null.
      active_member_hash.each_pair do |user_id, hash_entry|
        (0 ... hash_entry.row_index ).each do |row_index|
          if assignments[row_index][hash_entry.col_index].new_record?
            assignments[row_index][hash_entry.col_index].rotation_type = RotationType.no_op
          end
        end
      end
      # :rotation_type => RotationType.no_op,
      {
        :group => group,
        :members => members,
        :assignments => assignments
      }
    end
  end
end
