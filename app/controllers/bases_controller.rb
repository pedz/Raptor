# -*- coding: utf-8 -*-

class BasesController < ActionController::Base
  def index
    @redirect = false
    @redirect_array = []
    @options = { }
    argument_types = ArgumentType.all(:order => "position").each do |argument_type|
      # First see if we have an argument in this position.  Rails will
      # give it the name we want based upon what is in routes.rb
      if (v = params[argument_type.name]).nil?
        v = set_default(argument_type)
      end

      while (e = Entity.find_by_name(v)).nil?
        flash[:error] = "#{v} not known"
        v = set_default(argument_type)
      end
        
      # Redirect if type is not in the right place
      @redirect = true if e.argument_type.name != argument_type.name
      
      # See if this is the 2nd argument of this type
      unless @redirect_array[e.argument_type.position].nil?
        flash[:warning] = ("Multiple arguments specified for #{e.argument_type.name}"
                           " (position #{e.argument_type.position})")
        
      end
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
    v = argument_type.default
    # I hate special cases...
    v = application_user.current_retain_id.retid if v == "current_retuser_id"
    return v
  end
end

