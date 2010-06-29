# -*- coding: utf-8 -*-

module Combined
  # Favorite Queues Controller
  class FavoriteQueuesController < Retain::RetainController
    # GET /favorite_queues
    # Reponds to html, xml, and json formats
    def index
      @favorite_queues = application_user.favorite_queues.map { |queue|
        queue.wrap_with_combined
      }
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @favorite_queues }
        format.json
      end
    end
    
    # GET /favorite_queues/1
    # Responds to html and xml formats.
    def show
      @favorite_queue = Combined::FavoriteQueue.find(params[:id])
      
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @favorite_queue }
      end
    end
    
    # GET /favorite_queues/new
    # Responds to html and xml formats.
    def new
      center = signon_user.default_center
      queue = center.queues.build(:h_or_s => signon_user.default_h_or_s)
      @favorite_queue = Combined::FavoriteQueue.new(:queue => queue)
      # logger.debug("queue is of class #{@favorite_queue.queue.class}")
      # logger.debug("center is of class #{@favorite_queue.queue.center.class}")

      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @favorite_queue }
      end
    end
    
    # GET /favorite_queues/1/edit
    # Responds only with html format
    def edit
      @favorite_queue = Combined::FavoriteQueue.find(params[:id])
    end
    
    # POST /favorite_queues
    # Responds with html or xml format.
    def create
      center_options = params[:combined_center].symbolize_keys
      queue_options = params[:combined_queue].symbolize_keys
      center_options[:center].upcase!
      queue_options[:queue_name].upcase!
      queue_options[:queue_name].strip!
      queue_options[:h_or_s].upcase!
      options = center_options.merge(queue_options)

      if (center = Combined::Center.from_options(options)).nil?
        # logger.debug("bad center")
        flash[:error] = "Center is not valid"
        center = Combined::Center.new(options)
        queue = center.queues.build(queue_options)
        queue_valid = false
      else
        center.save if center.new_record?
        if (queue = center.queues.from_options(options)).nil?
          # logger.debug("bad queue")
          flash[:error] = "Queue is not valid"
          queue = center.queues.build(queue_options)
          queue_valid = false
        else
          queue_valid = true
        end
      end

      @favorite_queue = Combined::FavoriteQueue.new(:queue => queue,
                                                    :retuser => application_user.current_retain_id)
      respond_to do |format|
        if queue_valid && @favorite_queue.save
          flash[:notice] = 'FavoriteQueue was successfully created.'
          format.html { redirect_to(@favorite_queue) }
          format.xml  { render :xml => @favorite_queue, :status => :created, :location => @favorite_queue }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @favorite_queue.errors, :status => :unprocessable_entity }
        end
      end
    end
    
    # PUT /favorite_queues/1
    # Reponds with html and xml formats.
    def update
      # this is an odd case.  We do not actually want to change the
      # attributes of the queue because other people may be pointing
      # to the queue as their favorite queue.  It would also confused
      # a lot of other things like the calls assoicated with the
      # queue.
      #
      # So, we find or create a new queue with the new parameters and
      # then associate the favorite queue with this queue.
      #
      queue_options = params[:combined_queue]
      queue_options[:queue_name].upcase!
      queue_options[:queue_name].strip!
      queue_options[:center].upcase!
      queue_options[:h_or_s].upcase!
      queue = Combined::Queue.find(:first, :conditions => queue_options) ||
        Combined::Queue.new(queue_options)
      @favorite_queue = Combined::FavoriteQueue.find(params[:id])
      @favorite_queue.queue = queue

      if ! (queue_valid = Retain::Cq.check_queue(queue_options.symbolize_keys))
        flash[:error] = "Queue is not valid"
      end
      
      respond_to do |format|
        if queue_valid && @favorite_queue.save
          flash[:notice] = 'FavoriteQueue was successfully updated.'
          format.html { redirect_to(@favorite_queue) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @favorite_queue.errors, :status => :unprocessable_entity }
        end
      end
    end
    
    # DELETE /favorite_queues/1
    # Responds with html and xml formats.
    def destroy
      @favorite_queue = Combined::FavoriteQueue.find(params[:id])
      @favorite_queue.destroy
      
      respond_to do |format|
        format.html { redirect_to(combined_favorite_queues_url) }
        format.xml  { head :ok }
      end
    end
  end
end
