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

    def addtxt
      logger.debug("hi")
      fields = params[:id].split(',')
      options = {
        :problem => fields[0],
        :branch => fields[1],
        :country => fields[2]
      }
      logger.debug("options=#{options.inspect}")
      lines = params[:newtext].split("\n")
      logger.debug("lines before=#{lines.inspect}")
      lines = lines.map { |line|
        l = []
        while line.length > 72
          this_end = 72
          while this_end > 0 && line[this_end] != 0x20
            this_end -= 1
          end
          if this_end == 0      # no spaces found
            l << line[0 ... 72]
            line = line[72 ... line.length]
            next
          end
          
          new_start = this_end + 1
          while new_start < line.length && line[new_start] == 0x20
            new_start += 1
          end
          l << line[0 ... this_end]
          line = line[new_start ... line.length]
        end
        l << line
        l
      }.flatten
      logger.debug("lines after=#{lines.inspect}")
      options[:addtxt_lines] = lines
      addtxt = Retain::Pmat.new(options)
      begin
        addtxt.sendit(Retain::Fields.new)
      rescue Retain::SdiReaderError => e
        true
      end
      render(:update) { |page| page.replace_html 'addtxt-reply', "Addtxt rc = #{addtxt.rc}"}
    end

  end
end
