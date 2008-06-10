module Combined
  class PsarsController < Retain::RetainController
    # GET /combined_psars
    # GET /combined_psars.xml
    SEARCHABLE_FIELDS = [ :psar_number, :psar_start_date, :psar_end_date, :h_or_s, :psar_file_and_symbol ]

    def index
      # Note that the "signon2" field in the SDI "PSRR" request is for
      # the PSAR Employee number -- not the normal Retain signon.
      local_params = params.symbolize_keys
      retain_search_fields = Hash[ *local_params.select { |k, v| SEARCHABLE_FIELDS.include?(k)}.flatten ]
      db_search_fields = Cached::Psar.fields_only(local_params)
      psar_number = signon_user.psar_number

      if retuser = db_search_fields.delete("retuser_id")
        db_search_fields[:signon2] = Combined::Registration.find_or_initialize_by_signon(retuser).psar_number
      end

      # if not admin, then add in a condition that signon2 must match
      # current users psar_number
      unless admin?
        retain_search_fields[:signon2] = psar_number
        db_search_fields[:signon2] = psar_number
      end

      # If neither start nor end date is specified, we set start to
      # today and end to fourteen days ago -- because that seems to be
      # the limit anyway.
      unless (retain_search_fields.has_key?(:psar_start_date) ||
              retain_search_fields.has_key?(:psar_end_date))
        retain_search_fields[:psar_end_date] = Time.now.strftime("%Y%m%d")
        retain_search_fields[:psar_start_date] = (Time.now - 14.days).strftime("%Y%m%d")
      end

      # See if we can do a search within Retain.  We just add these to
      # the database if we hit any.
      retain_search_fields[:group_request] = [ [ :psar_file_and_symbol ] ]
      first_field = Combined::Psar.retain_fields.first
      begin
        de32s = Retain::Psar.new(retain_search_fields).de32s
      rescue Retain::SdiReaderError => e
        raise e unless e.rc == 256
      else
        de32s.each do |fields|
          combined = Combined::Psar.find_or_new :psar_file_and_symbol => fields.psar_file_and_symbol
          # Cause a touch
          combined.send first_field
        end
      end
      
      if db_search_fields.empty?
        @combined_psars = Combined::Psar.find(:all)
      else
        @combined_psars = Combined::Psar.find(:all, :conditions => db_search_fields)
      end
      
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
      @combined_psar.destroy
      
      respond_to do |format|
        format.html { redirect_to(combined_psars_url) }
        format.xml  { head :ok }
      end
    end
  end
end
