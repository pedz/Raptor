module Json
  class ViewsController < ApplicationController
    # This is the way that the javascript pulls over the view that the
    # user wants to display.  We send over the view, the elements, and
    # the widgets that are associated with the view and elements.
    def index
      views = View.find_by_name(params[:view], :include => [ { :elements => :widget } ] )
      render :json => views.to_json(:include => { :elements => { :include => :widget } })
    end
  end
end
