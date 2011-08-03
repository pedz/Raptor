# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Retain
  class ServiceActionCauseTuplesController < ApplicationController
    # GET /retain_service_action_cause_tuples
    # GET /retain_service_action_cause_tuples.xml
    def index
      @retain_service_action_cause_tuples = Retain::ServiceActionCauseTuple.find(:all)
      
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @retain_service_action_cause_tuples }
      end
    end
    
    # GET /retain_service_action_cause_tuples/1
    # GET /retain_service_action_cause_tuples/1.xml
    def show
      @retain_service_action_cause_tuple = Retain::ServiceActionCauseTuple.find(params[:id])
      
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @retain_service_action_cause_tuple }
      end
    end
    
    # GET /retain_service_action_cause_tuples/new
    # GET /retain_service_action_cause_tuples/new.xml
    def new
      @retain_service_action_cause_tuple = Retain::ServiceActionCauseTuple.new
      
      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @retain_service_action_cause_tuple }
      end
    end
    
    # GET /retain_service_action_cause_tuples/1/edit
    def edit
      @retain_service_action_cause_tuple = Retain::ServiceActionCauseTuple.find(params[:id])
    end
    
    # POST /retain_service_action_cause_tuples
    # POST /retain_service_action_cause_tuples.xml
    def create
      @retain_service_action_cause_tuple = Retain::ServiceActionCauseTuple.new(params[:retain_service_action_cause_tuple])
      
      respond_to do |format|
        if @retain_service_action_cause_tuple.save
          flash[:notice] = 'ServiceActionCauseTuple was successfully created.'
          format.html { redirect_to(@retain_service_action_cause_tuple) }
          format.xml  { render :xml => @retain_service_action_cause_tuple, :status => :created, :location => @retain_service_action_cause_tuple }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @retain_service_action_cause_tuple.errors, :status => :unprocessable_entity }
        end
      end
    end
    
    # PUT /retain_service_action_cause_tuples/1
    # PUT /retain_service_action_cause_tuples/1.xml
    def update
      @retain_service_action_cause_tuple = Retain::ServiceActionCauseTuple.find(params[:id])
      
      respond_to do |format|
        if @retain_service_action_cause_tuple.update_attributes(params[:retain_service_action_cause_tuple])
          flash[:notice] = 'ServiceActionCauseTuple was successfully updated.'
          format.html { redirect_to(@retain_service_action_cause_tuple) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @retain_service_action_cause_tuple.errors, :status => :unprocessable_entity }
        end
      end
    end
    
    # DELETE /retain_service_action_cause_tuples/1
    # DELETE /retain_service_action_cause_tuples/1.xml
    def destroy
      @retain_service_action_cause_tuple = Retain::ServiceActionCauseTuple.find(params[:id])
      @retain_service_action_cause_tuple.destroy
      
      respond_to do |format|
        format.html { redirect_to(retain_service_action_cause_tuples_url) }
        format.xml  { head :ok }
      end
    end
  end
  
end
