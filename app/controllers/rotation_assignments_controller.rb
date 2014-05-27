class RotationAssignmentsController < ApplicationController
  def create
    @rotation_assignment = RotationAssignment.new(params[:rotation_assignment])
    @rotation_assignment.save
    respond_to do |format|
      format.html { redirect_to(qm_path(@rotation_assignment.rotation_group.queue.item_name), :notice => "Yippee") }
    end
  end
end
