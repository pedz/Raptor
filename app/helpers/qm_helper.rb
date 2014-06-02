module QmHelper
  def show_qm_tables
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
      @col_index += 1
      @assignment = assignment
      render(:partial => 'show_cell')
    end.join("\n")
  end

  def show_qm_cell
    unless blank_cell?
      if form_needed?
        @members[@col_index] = nil # only one form per member
        render(:partial => 'cell_form')
      else
        "<div class='edit-assignment' style='display: none;'>" +
          render(:partial => 'cell_form') +
        "</div>" +
        "<div class='show-assignment'>" +
          render(:partial => 'cell_text') +
        "</div>"
      end
    end
  end
  
  # Returns true if the cell will be blank
  def blank_cell?
    # A nil assignment creates a blank cell
    return true if @assignment.nil?

    # A form previously in this member's column implies that all cells
    # below are empty
    return true if @members[@col_index].nil?

    # Otherwise, the cell is not blank
    return false
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
