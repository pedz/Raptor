# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

# Favorite Queues Controller
class FavoriteQueuesController < Retain::RetainController
  # GET /favorite_queues
  # Reponds to html, xml, and json formats
  def index
    @favorite_queue_hashes = application_user.favorite_queues.map do |favorite_queue|
      queue = favorite_queue.queue.wrap_with_combined
      hits = queue.hits(:html)
      team = (hits >= 0) && queue.owners.empty?
      q_class = ((team ? "team" : "personal") +
                                ((hits == 0) ? "-empty" : "-nonempty"))
      {
        :favorite_queue => favorite_queue,
        :id => favorite_queue.id,
        :queue => queue,
        :hits => hits,
        :team => team,
        :q_class => q_class
      }
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @favorite_queues }
      format.json
    end
  end
  
  # GET /favorite_queues/expanded
  # Provides a list of all the PMRs on all the queues listed in a
  # person's favorite queues list.  This view uses mostly JSON and
  # Javascript to do its rendering but the initial request is assumed
  # to be HTML for now.
  def expanded
    # Page -- right now, is empty.
    # @favorite_queues = application_user.favorite_queues
  end

  # GET /favorite_queues/1
  # Responds to html and xml formats.
  def show
    @favorite_queue = FavoriteQueue.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @favorite_queue }
    end
  end
  
  # GET /favorite_queues/new
  # Responds to html and xml formats.
  def new
    center = signon_user.default_center
    # logger.debug("center is of class #{center.class}")
    queue = center.queues.build(:h_or_s => signon_user.default_h_or_s)
    queue = queue.unwrap_to_cached if queue.respond_to? :unwrap_to_cached
    # logger.debug("queue is of class #{queue.class}")
    @favorite_queue = FavoriteQueue.new(:queue => queue)
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
    @favorite_queue = FavoriteQueue.find(params[:id])
  end
  
  # POST /favorite_queues
  # Responds with html or xml format.
  def create
    center_options = params[:cached_center].symbolize_keys
    queue_options = params[:cached_queue].symbolize_keys
    center_options[:center].upcase!
    queue_options[:queue_name].upcase!
    queue_options[:queue_name].strip!
    queue_options[:h_or_s].upcase!
    options = center_options.merge(queue_options)
    
    # We create the new center and queue (if we need to) as Combined
    # so that things get refreshed but then unwrap them.
    if (center = Cached::Center.from_options(retain_user_connection_parameters, options)).nil?
      # logger.debug("bad center")
      flash[:error] = "Center is not valid"
      center = Combined::Center.new(options)
      queue = center.queues.build(queue_options)
      queue_valid = false
    else
      center.save if center.new_record?
      if (queue = center.queues.from_options(retain_user_connection_parameters, options)).nil?
        # logger.debug("bad queue")
        flash[:error] = "Queue is not valid"
        queue = center.queues.build(queue_options)
        queue_valid = false
      else
        queue_valid = true
      end
    end
    queue = queue.unwrap_to_cached
    center = center.unwrap_to_cached

    @favorite_queue =
      FavoriteQueue.new(:queue => queue,
                        :retuser => retain_user,
                        :sort_column => application_user.favorite_queues.size)

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
  
## The code below is broken since the change to favorite queues is a
## cached thing and not a combined thing.  The call to
## Retain::Cq.check_queue doesn't even exist anymore.  We will need to
## fix this eventually but not today.
##
##   # PUT /favorite_queues/1
##   # Reponds with html and xml formats.
##   def update
##     # this is an odd case.  We do not actually want to change the
##     # attributes of the queue because other people may be pointing
##     # to the queue as their favorite queue.  It would also confused
##     # a lot of other things like the calls assoicated with the
##     # queue.
##     #
##     # So, we find or create a new queue with the new parameters and
##     # then associate the favorite queue with this queue.
##     #
##     queue_options = params[:combined_queue]
##     queue_options[:queue_name].upcase!
##     queue_options[:queue_name].strip!
##     queue_options[:center].upcase!
##     queue_options[:h_or_s].upcase!
##     queue = Combined::Queue.find(:first, :conditions => queue_options) ||
##       Combined::Queue.new(queue_options)
##     @favorite_queue = FavoriteQueue.find(params[:id])
##     @favorite_queue.queue = queue
##     
##     if ! (queue_valid = Retain::Cq.check_queue(queue_options.symbolize_keys))
##       flash[:error] = "Queue is not valid"
##     end
##     
##     respond_to do |format|
##       if queue_valid && @favorite_queue.save
##         flash[:notice] = 'FavoriteQueue was successfully updated.'
##         format.html { redirect_to(@favorite_queue) }
##         format.xml  { head :ok }
##       else
##         format.html { render :action => "edit" }
##         format.xml  { render :xml => @favorite_queue.errors, :status => :unprocessable_entity }
##       end
##     end
##   end

  # DELETE /favorite_queues/1
  # Responds with html and xml formats.
  def destroy
    @favorite_queue = FavoriteQueue.find(params[:id])
    @favorite_queue.destroy
    
    respond_to do |format|
      format.html { redirect_to(favorite_queues_url) }
      format.xml  { head :ok }
    end
  end

  def sort
    # the order the user wants the ids to be in
    list = params[:favorite_queues].map { |s| s.to_i }
    @favorite_queues = application_user.favorite_queues
    len = @favorite_queues.length
    @favorite_queues.each do |fq|
      if (p = list.index(fq.id)).nil?
        p = len
        len += 1
      end
      fq.sort_column = p
      fq.save
    end
    render :update do |page|
    end
  end
end
