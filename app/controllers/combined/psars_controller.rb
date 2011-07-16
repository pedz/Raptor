# -*- coding: utf-8 -*-

module Combined
  class PsarsController < Retain::RetainController
    # This is not currently used but it is the list of attributes that
    # can be searched via the retain interface.
    SEARCHABLE_FIELDS = [ :psar_number,
                          :psar_start_date,
                          :psar_end_date,
                          :h_or_s,
                          :psar_file_and_symbol ]

    # GET /combined_psars
    # GET /combined_psars.xml
    # Retrieve the PSARs.  Accepts various search conditions.
    # Admins may retrieve PSARs for users other than themselves.
    def index
      local_params = params.symbolize_keys

      if local_params.has_key? :ice_cream
        render :action => :brf
        return
      end

      # The default is to find the PSAR for the current user.
      retuser = local_params.delete(:retuser_id) || signon_user.signon
      
      # Only admins can search for others
      unless admin? || retuser == signon_user.signon
        render :status => 401, :layout => false, :file => "public/401.html"
        return
      end
      req_user = Cached::Registration.from_options(retain_user_connection_parameters, { :signon => retuser })
      if @no_cache
        req_user.refresh
      end
      db_search_fields = Cached::Psar.fields_only(local_params)

      # Notes: The stop_time is in the customer's timezone.  We can
      # find the customer's timezone by looking up the customer.  And
      # then we can decide if the start of the day is midnight local
      # time or midnight GMT or midnight at the center.  Probably
      # midnight local time since that is how the user will view it.
      # While we currently don't fetch the customer's timezone, we
      # could and then do the select based upon a join and a computed
      # stop time in GMT.
      if local_params.has_key? :psar_start_date
        str = local_params[:psar_start_date]
        start_moc = Time.local(str[0...4].to_i, str[4...6].to_i, str[6...8].to_i).moc
      else
        start_moc = 0
      end
      
      if local_params.has_key? :psar_stop_date
        str = local_params[:psar_stop_date]
        stop_moc = Time.local(str[0...4].to_i, str[4...6].to_i, str[6...8].to_i).moc
      else
        stop_moc = 999999999
      end

      # Just to make it look prettier
      psar_proxy = req_user.psars.stop_time_range(start_moc .. stop_moc)
      @combined_psars = psar_proxy.find(:all,
                                        :conditions => db_search_fields,
                                        :include => :pmr)
      
      # logger.debug("psars_controller #{@combined_psars[0].class}")
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @combined_psars }
      end
    end
    
    # GET /combined_psars/1
    # GET /combined_psars/1.xml
    def show
      id = params[:id]
      # If id contains only digits, its a database id.  Otherwise, it
      # is a psar_file_and_symbol.  In that case, we search retain to
      # see if we can find it before consulting the database.
      if id.match(/[^0-9]/)
        @combined_psar = Combined::Psar.find_or_new :psar_file_and_symbol => id
      else
        @combined_psar = Combined::Psar.find(params[:id])
      end
      
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @combined_psar }
      end
    end
    
    # GET /combined_psars/new
    # GET /combined_psars/new.xml
    def new
      @combined_psar = Combined::Psar.new
      
      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @combined_psar }
      end
    end
    
    # GET /combined_psars/1/edit
    def edit
      id = params[:id]
      # If id contains only digits, its a database id.  Otherwise, it
      # is a psar_file_and_symbol.  In that case, we search retain to
      # see if we can find it before consulting the database.
      if id.match(/[^0-9]/)
        @combined_psar = Combined::Psar.find_or_new :psar_file_and_symbol => id
      else
        @combined_psar = Combined::Psar.find(params[:id])
      end
    end
    
    # POST /combined_psars
    # POST /combined_psars.xml
    def create
      @combined_psar = CombinedPsar.new(params[:combined_psar])
      
      respond_to do |format|
        if @combined_psar.save
          flash[:notice] = 'CombinedPsar was successfully created.'
          format.html { redirect_to(@combined_psar) }
          format.xml  { render(:xml => @combined_psar,
                               :status => :created,
                               :location => @combined_psar) }
        else
          format.html { render :action => "new" }
          format.xml  { render(:xml => @combined_psar.errors,
                               :status => :unprocessable_entity) }
        end
      end
    end
    
    # PUT /combined_psars/1
    # PUT /combined_psars/1.xml
    def update
      id = params[:id]
      # If id contains only digits, its a database id.  Otherwise, it
      # is a psar_file_and_symbol.  In that case, we search retain to
      # see if we can find it before consulting the database.
      if id.match(/[^0-9]/)
        @combined_psar = Combined::Psar.find_or_new :psar_file_and_symbol => id
      else
        @combined_psar = Combined::Psar.find(params[:id])
      end
      
      respond_to do |format|
        if @combined_psar.update_attributes(params[:combined_psar])
          flash[:notice] = 'CombinedPsar was successfully updated.'
          format.html { redirect_to(@combined_psar) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render(:xml => @combined_psar.errors,
                               :status => :unprocessable_entity) }
        end
      end
    end
    
    # DELETE /combined_psars/1
    # DELETE /combined_psars/1.xml
    def destroy
      id = params[:id]
      # If id contains only digits, its a database id.  Otherwise, it
      # is a psar_file_and_symbol.  In that case, we search retain to
      # see if we can find it before consulting the database.
      if id.match(/[^0-9]/)
        @combined_psar = Combined::Psar.find_or_new :psar_file_and_symbol => id
      else
        @combined_psar = Combined::Psar.find(params[:id])
      end
      value = @combined_psar.destroy
      # logger.debug("Value is #{value}")
      
      respond_to do |format|
        format.html { redirect_to(combined_psars_url) }
        format.xml  { head :ok }
      end
    end
  end
end
