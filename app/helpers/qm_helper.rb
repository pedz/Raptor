module QmHelper
  def show_qm_tables
    @rotation_groups.map do |group|
      @group = group[:group]
      @members = group[:members]
      @assignments = group[:assignments]
      render(:partial => 'show_table')
    end.join("\n")
  end

  def show_qm_table_header
    content_tag("tr", member_name_row) +
      content_tag("tr", member_queue_row)
  end

  def member_name_row
    @members.map { |member|
      content_tag("th", member.name)
    }.join("\n")
  end

  def member_queue_row
    @members.map { |member|
      content_tag("th") do
        link_to(member.queue_name, combined_queue_path(member.queue.item_name)) +
          "(#{member.queue.hot_calls.size}/#{member.queue.unique_calls.size})"
      end
    }.join("\n")
  end
  
  def show_qm_table_body
    @row_index = -1
    @first_row_with_form = nil
    @assignments.map do |row|
      @row_index += 1
      @row = row
      render(:partial => 'show_row')
    end[@first_row_with_form .. -1].join("\n")
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
        @first_row_with_form = [@row_index - 2, 0].max unless @first_row_with_form
        @members[@col_index] = nil # only one form per member
        render(:partial => 'cell_form')
      else
        content_tag("div", :class => 'edit-assignment', :style => 'display:none;') do
          render(:partial => 'cell_form')
        end +
          content_tag("div", :class => 'show-assignment') do
          render(:partial => 'cell_text')
        end
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
    @assignment.rotation_type.auto_skip?
  end
end
