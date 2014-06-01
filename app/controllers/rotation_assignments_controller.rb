class RotationAssignmentsController < ApplicationController
  def create
  end

  # params[:id] is set to the id of the QM being monitored which is
  # the Retain queue.  e.g. it will be set to "WWNETK,S,165".  This
  # can be used in the redirect.  params[:rotation_assignment] is what
  # is used to create or update the rotation_assignment.
  def qm_create
    qm_id = params[:id]
    assignment = RotationAssignment.new(params[:rotation_assignment])
    logger.debug "PMR = '#{assignment.pmr}'"
    group = assignment.rotation_group
    auto_skip = RotationType.find_by_name('auto-skip')
    
    if assignment.valid?
      begin
        group.transaction do
          fill_with_auto_skip(group, assignment)
          
          # We now do what the "next_type" tells us to do.
          next_type = assignment.rotation_type.next_type
          
          # If the name is "no-op" we do nothing or if the next_type
          # FIXME: the "no-op" string should be global or something.
          unless next_type.name == "no-op"
            next_group = next_type.rotation_group
            
            # See if we can find an auto-skip for this assign_to and the
            # next_group
            l = RotationAssignment.find(:all,
                                        :conditions => {
                                          :rotation_group_id => next_group.id,
                                          :assigned_to => assignment.assigned_to,
                                          :rotation_type_id => auto_skip.id
                                        }).first
            if l
              l.update_attributes({
                                    :pmr => assignment.pmr,
                                    :assigned_by => assignment.assigned_by,
                                    :rotation_type_id => next_type.id,
                                    :notes => ""
                                  })
            else
              # Not really complete... need to do the auto skip stuff
              fill_with_auto_skip(next_group, RotationAssignment.new({
                                                                       :rotation_group_id => next_group.id,
                                                                       :pmr => assignment.pmr,
                                                                       :assigned_by => assignment.assigned_by,
                                                                       :assigned_to => assignment.assigned_to,
                                                                       :rotation_type_id => next_type.id,
                                                                       :notes => ""
                                                                     }))
            end
          end
        end
      rescue
        flash[:error] = "Something bad happened"
      end
    else
      flash[:error] = assignment.errors.each_full { |msg| msg}.join('<br \>')
    end
    
    # We start a transaction so all of this is atomic and rolls back
    # if there is an error anywhere.
    respond_to do |format|
      format.html { redirect_to(qm_path(qm_id)) }
    end
  end

  def qm_update
    qm_id = params[:id]
    assignment_hash = params[:rotation_assignment]
    assignment = RotationAssignment.find(assignment_hash.delete(:id))
    unless assignment.update_attributes(assignment_hash)
      flash[:error] = assignment.errors.each_full { |msg| msg}.join('<br \>')
    end
    respond_to do |format|
      format.html { redirect_to(qm_path(qm_id)) }
    end
  end

  private

  def fill_with_auto_skip(group, assignment)
    user_ids = group.active_group_members.map { |member| member.user.id }
    # user_ids are two sequences of each user's id
    user_ids = user_ids + user_ids
    last_user_id = group.rotation_assignments.last.assigned_to
    next_user_id = assignment.assigned_to
    auto_skip = RotationType.find_by_name('auto-skip')

    # We run through the user ids until we find the one that matches
    # the id of the last rotation assignment and we set triggered to
    # true.  Then we add auto-sip entries for each user until we get
    # to the one we need to assign the real rotation assignment to and
    # stop.
    triggered = false
    user_ids.each do |user_id|
      break if triggered && next_user_id == user_id
      if triggered
        RotationAssignment.create!(:rotation_group_id => group.id,
                                   :pmr => "",
                                   :assigned_by => assignment.assigned_by,
                                   :assigned_to => user_id,
                                   :rotation_type_id => auto_skip.id,
                                   :notes => "Auto Filled")
      end
      triggered = true if last_user_id == user_id
    end

    # We save the original rotation assignment.
    assignment.save
  end
end
