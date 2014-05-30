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
    group = assignment.rotation_group
    user_ids = group.sorted_group_members.map { |member| member.user.id }
    user_ids = user_ids + user_ids
    last_user_id = group.sorted_assignments.last.assigned_to
    next_user_id = assignment.assigned_to
    triggered = false
    auto_skip = RotationType.find_by_name('auto-skip')
    group.transaction do
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
      assignment.save
    end
    respond_to do |format|
      format.html { redirect_to(qm_path(qm_id), :notice => "Yippee") }
    end
  end

  def qm_update
    qm_id = params[:id]
    assignment_hash = params[:rotation_assignment]
    assignment = RotationAssignment.find(assignment_hash.delete(:id))
    assignment.update_attributes(assignment_hash)
    respond_to do |format|
      format.html { redirect_to(qm_path(qm_id), :notice => "Yippee") }
    end
  end
end
