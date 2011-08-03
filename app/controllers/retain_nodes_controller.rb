# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
class RetainNodesController < ApplicationController
  before_filter :admin_only

  # GET /retain_nodes
  # GET /retain_nodes.xml
  # GET /retain_nodes.json
  def index
    @retain_nodes = RetainNode.all

    respond_to do |format|
      format.html  # index.html.erb
      format.xml   { render :xml   => @retain_nodes }
      format.json  { render :json => @retain_nodes }
    end
  end

  # GET /retain_nodes/1
  # GET /retain_nodes/1.xml
  # GET /retain_nodes/1.json
  def show
    @retain_node = RetainNode.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @retain_node }
      format.json  { render :json => @retain_node }
    end
  end

  # GET /retain_nodes/new
  # GET /retain_nodes/new.xml
  # GET /retain_nodes/new.json
  def new
    @retain_node = RetainNode.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @retain_node }
      format.json  { render :json => @retain_node }
    end
  end

  # GET /retain_nodes/1/edit
  def edit
    @retain_node = RetainNode.find(params[:id])
  end

  # POST /retain_nodes
  # POST /retain_nodes.xml
  # POST /retain_nodes.json
  def create
    @retain_node = RetainNode.new(params[:retain_node])

    respond_to do |format|
      if @retain_node.save
        flash[:notice] = 'RetainNode was successfully created.'
        format.html { redirect_to(@retain_node) }
        format.xml  { render :xml => @retain_node, :status => :created, :location => @retain_node }
        format.json  { render :json => @retain_node, :status => :created, :location => @retain_node }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @retain_node.errors, :status => :unprocessable_entity }
        format.json  { render :json => @retain_node.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /retain_nodes/1
  # PUT /retain_nodes/1.xml
  # PUT /retain_nodes/1.json
  def update
    @retain_node = RetainNode.find(params[:id])

    respond_to do |format|
      if @retain_node.update_attributes(params[:retain_node])
        flash[:notice] = 'RetainNode was successfully updated.'
        format.html { redirect_to(@retain_node) }
        format.xml  { head :ok }
        format.json  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @retain_node.errors, :status => :unprocessable_entity }
        format.json  { render :json => @retain_node.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /retain_nodes/1
  # DELETE /retain_nodes/1.xml
  # DELETE /retain_nodes/1.json
  def destroy
    @retain_node = RetainNode.find(params[:id])
    @retain_node.destroy

    respond_to do |format|
      format.html { redirect_to(retain_nodes_url) }
      format.xml  { head :ok }
      format.json  { head :ok }
    end
  end
  
  private
  
  def admin_only
    unless admin?
      flash[:notice] = "Not Permitted"
      redirect_to(:controller => "welcome", :action => "index", :status => 401)
    end
  end
end
