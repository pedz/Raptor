module Combined
  class PsarsController < Retain::RetainController
    # GET /combined_psars
    # GET /combined_psars.xml
    SEARCHABLE_FIELDS = [ :psar_number, :psar_start_date, :psar_end_date, :h_or_s, :psar_file_and_symbol ]

    # Retrieve the PSARs.  Accepts various search conditions.
    # Admins may retrieve PSARs for users other than themselves.
    def index
      # Note that the "signon2" field in the SDI "PSRR" request is for
      # the PSAR Employee number -- not the normal Retain signon.
      local_params = params.symbolize_keys
      retuser = local_params.delete(:retuser_id)
      
      # Default to current user
      retuser = signon_user.signon if retuser.nil?
      
      # Only admins can search for others
      unless admin? || retuser == signon_user.signon
        render :status => 401, :layout => false, :file => "public/401.html"
        return
      end
      req_user = Combined::Registration.from_options :signon => retuser
      
      db_search_fields = Cached::Psar.fields_only(local_params)
      
      if db_search_fields.empty?
        logger.debug("psars_controller 1 #{req_user.class}")
        @combined_psars = req_user.psars.find(:all)
      else
        logger.debug("psars_controller 2")
        @combined_psars = req_user.psars.find(:all, :conditions => db_search_fields)
      end
      
      logger.debug("psars_controller #{@combined_psars[0].class}")
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
          format.xml  { render :xml => @combined_psar, :status => :created, :location => @combined_psar }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @combined_psar.errors, :status => :unprocessable_entity }
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
          format.xml  { render :xml => @combined_psar.errors, :status => :unprocessable_entity }
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
      logger.debug("Value is #{value}")
      
      respond_to do |format|
        format.html { redirect_to(combined_psars_url) }
        format.xml  { head :ok }
      end
    end
  end
end
