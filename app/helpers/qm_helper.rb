module QmHelper
  def show_qm_table
    @rotation_groups.map do |group|
      @group = group[:group]
      @members = group[:members]
      @assignments = group[:assignments]
      render(:partial => 'show_table')
    end.join("\n")
  end

  def show_qm_assignments
    @row_index = -1
    @assignments.map do |row|
      @row_index += 1
      @row = row
      render(:partial => 'show_row')
    end.join("\n")
  end

  def show_qm_row
    @col_index = -1
    @row.map do |assignment|
      logger.debug "here"
      @col_index += 1
      @assignment = assignment
      render(:partial => 'show_cell')
    end.join("\n")
  end

  def show_qm_cell
    unless blank_cell?
      if form_needed?
        render(:partial => 'cell_form')
      else
        # <div class='edit-assignment' style='display: none;'>
        #   <%= render(:partial => 'cell_form') %>
        # </div>
        # <div class='show-assignment'>
        render(:partial => 'cell_text')
        # </div>
      end
    end
  end
  
  # Returns true if the cell will be blank
  def blank_cell?
    # If this member already has a visable form then this cell will be
    # blank
    return true unless @members[@col_index]

    # if assignment is nil, cell will be blank
    return true unless @assignment

    # if new record, cell will not be blank (at this point)
    return false if @assignment.new_record?

    # If this is an auto-skip, then make it a form and skip the rest
    # of cells for this member
    if @assignment.rotation_type.name == 'auto-skip'
      @members[@col_index] = nil
    end

    # cell will not be blank
    false
  end

  # Returns true if a form is needed
  def form_needed?
    # Not really needed due to outer logic but we do this anyway
    return false if @assignment.nil?

    # New records need a form
    return true if @assignment.new_record?

    # auto-skips need a form
    @assignment.rotation_type.name == 'auto-skip'
  end
end
