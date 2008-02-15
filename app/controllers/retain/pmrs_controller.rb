module Retain
  class PmrsController < RetainController
    # GET /retain_pmrs
    # GET /retain_pmrs.xml
    def index
      @retain_pmrs = RetainPmr.find(:all)
      
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @retain_pmrs }
      end
    end
    
    # GET /retain_pmrs/1
    # GET /retain_pmrs/1.xml
    def show
      @retain_pmr = RetainPmr.find(params[:id])
      
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @retain_pmr }
      end
    end
    
    # GET /retain_pmrs/new
    # GET /retain_pmrs/new.xml
    def new
      @retain_pmr = RetainPmr.new
      
      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @retain_pmr }
      end
    end
    
    # GET /retain_pmrs/1/edit
    def edit
      @retain_pmr = RetainPmr.find(params[:id])
    end
    
    # POST /retain_pmrs
    # POST /retain_pmrs.xml
    def create
      @retain_pmr = RetainPmr.new(params[:retain_pmr])
      
      respond_to do |format|
        if @retain_pmr.save
          flash[:notice] = 'RetainPmr was successfully created.'
          format.html { redirect_to(@retain_pmr) }
          format.xml  { render :xml => @retain_pmr, :status => :created, :location => @retain_pmr }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @retain_pmr.errors, :status => :unprocessable_entity }
        end
      end
    end
    
    # PUT /retain_pmrs/1
    # PUT /retain_pmrs/1.xml
    def update
      @retain_pmr = RetainPmr.find(params[:id])
      
      respond_to do |format|
        if @retain_pmr.update_attributes(params[:retain_pmr])
          flash[:notice] = 'RetainPmr was successfully updated.'
          format.html { redirect_to(@retain_pmr) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @retain_pmr.errors, :status => :unprocessable_entity }
        end
      end
    end
    
    # DELETE /retain_pmrs/1
    # DELETE /retain_pmrs/1.xml
    def destroy
      @retain_pmr = RetainPmr.find(params[:id])
      @retain_pmr.destroy
      
      respond_to do |format|
        format.html { redirect_to(retain_pmrs_url) }
        format.xml  { head :ok }
      end
    end

    def alter
      # We blow off fetching the PMR.
      words = params[:id].split(',')
      field = params[:editorId].to_sym
      new_text = params[:value]
      options = {
        :problem => words[0],
        :branch => words[1],
        :country => words[2],
        field => new_text
      }
      # pmpu = Retain::Pmpu.new(options)
      # fields = Retain::Fields.new
      # pmpu.sendit(fields)
      # rc = pmpu.rc
      new_text = "<span class='wag-wag'>banana</span>"
      rc = 0
      respond_to do |format|
        if rc == 0
          format.html { render :text => new_text }
          format.xml  { logger.info("RTN: xml")  }
        else
          format.html { render(:text => new_text,
                               :status => :unprocessable_entity) }
          format.xml  { logger.info("RTN: xml")  }
        end
      end
    end
  end
end
