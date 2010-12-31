# -*- coding: utf-8 -*-

module Retain
  class QueueInfosController < RetainController
    # GET /combined_queue_infos
    # GET /combined_queue_infos.xml
    def index
      @queue_infos = Combined::QueueInfo.find(:all)
      
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @combined_queue_infos }
      end
    end
    
    # GET /combined_queue_infos/1
    # GET /combined_queue_infos/1.xml
    def show
      @queue_info = Combined::QueueInfo.find(params[:id])
      
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @queue_info }
      end
    end
    
    # GET /combined_queue_infos/new
    # GET /combined_queue_infos/new.xml
    def new
      @queue_info = Combined::QueueInfo.new
      center = signon_user.default_center
      queues = center.queues.team_queues + center.queues.personal_queues
      @queue_list = Combined::Queue.find(:all).collect { |q|
        [ q.to_param, q.id ]
      }.sort

      @reg_list = Combined::Registration.find(:all,
                                              :conditions =>
                                              { :apptest => @params.apptest}).collect { |r|
        [ r.name, r.id ] }.sort

      # @queue_list = queues.collect { |q| [ q.to_param, q.id ] }
      # @reg_list = center.registrations.collect { |r| [ r.name, r.id ] }.sort

      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @queue_info }
      end
    end
    
    # GET /combined_queue_infos/1/edit
    def edit
      @queue_info = Combined::QueueInfo.find(params[:id])
    end
    
    # POST /combined_queue_infos
    # POST /combined_queue_infos.xml
    def create
      @queue_info = Combined::QueueInfo.new(params[:combined_queue_info])
      
      respond_to do |format|
        if @queue_info.save
          flash[:notice] = 'Combined::QueueInfo was successfully created.'
          format.html { redirect_to(@queue_info) }
          format.xml  { render :xml => @queue_info, :status => :created, :location => @queue_info }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @queue_info.errors, :status => :unprocessable_entity }
        end
      end
    end
    
    # PUT /combined_queue_infos/1
    # PUT /combined_queue_infos/1.xml
    def update
      @queue_info = Combined::QueueInfo.find(params[:id])
      
      respond_to do |format|
        if @queue_info.update_attributes(params[:combined_queue_info])
          flash[:notice] = 'Combined::QueueInfo was successfully updated.'
          format.html { redirect_to(@queue_info) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @queue_info.errors, :status => :unprocessable_entity }
        end
      end
    end
    
    # DELETE /combined_queue_infos/1
    # DELETE /combined_queue_infos/1.xml
    def destroy
      @queue_info = Combined::QueueInfo.find(params[:id])
      @queue_info.destroy
      
      respond_to do |format|
        format.html { redirect_to(combined_queue_infos_url) }
        format.xml  { head :ok }
      end
    end
  end
end
