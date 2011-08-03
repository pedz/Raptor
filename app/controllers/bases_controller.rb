# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

class BasesController < Retain::RetainController
  def index
    @redirect = false
    @argument_array = []
    @redirect_array = []
    @options = { }
    argument_types = ArgumentType.all(:order => "position").each do |argument_type|
      # First see if we have an argument in this position.  Rails will
      # give it the name we want based upon what is in routes.rb
      if (v = params[argument_type.name]).nil?
        v = set_default(argument_type)
      end

      while (e = Entity.find_by_name(v)).nil?
        d = set_default(argument_type)
        if v == d
          raise "Default not found"
        end
        flash[:error] = "#{v} not known"
        v = d
      end
        
      # Redirect if type is not in the right place
      @redirect = true if e.argument_type.name != argument_type.name
      
      # See if this is a duplicate argument of this type
      unless @redirect_array[e.argument_type.position].nil?
        flash[:warning] = ("Multiple arguments specified for #{e.argument_type.name}"
                           " (position #{e.argument_type.position})")
        
      end
      @argument_array[e.argument_type.position] = e
      @redirect_array[e.argument_type.position] = v
      @options[e.argument_type.name] = v
    end

    if @redirect
      redirect_to(@options)
    else
      @widgets = View.find_by_name(@options["view"]).widgets.map { |widget| "widgets/#{widget.name}"}
      render
    end
  end

  private

  def set_default(argument_type)
    @redirect = true
    unless (arg0 = @argument_array[0]).nil? # unless argument position 0 has not been set
      raise "First argument must be a Name" unless arg0.base_type == 'Name'
      item = arg0.item
      argument_default = item.argument_defaults.find_by_argument_position(argument_type.position)
      return argument_default.default unless argument_default.nil?
    end

    v = argument_type.default
    # I hate special cases...
    v = retain_user.retid if v == "current_retuser_id"
    return v
  end
end

