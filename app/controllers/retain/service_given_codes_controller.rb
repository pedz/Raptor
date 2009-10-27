# -*- coding: utf-8 -*-

module Retain
  class ServiceGivenCodesController < ApplicationController
    # GET /retain_service_given_codes
    # GET /retain_service_given_codes.xml
    def index
      @retain_service_given_codes = Retain::ServiceGivenCode.find(:all)
      
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @retain_service_given_codes }
      end
    end
    
    # GET /retain_service_given_codes/1
    # GET /retain_service_given_codes/1.xml
    def show
      @retain_service_given_code = Retain::ServiceGivenCode.find(params[:id])
      
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @retain_service_given_code }
      end
    end
    
    # GET /retain_service_given_codes/new
    # GET /retain_service_given_codes/new.xml
    def new
      @retain_service_given_code = Retain::ServiceGivenCode.new
      
      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @retain_service_given_code }
      end
    end
    
    # GET /retain_service_given_codes/1/edit
    def edit
      @retain_service_given_code = Retain::ServiceGivenCode.find(params[:id])
    end
    
    # POST /retain_service_given_codes
    # POST /retain_service_given_codes.xml
    def create
      @retain_service_given_code = Retain::ServiceGivenCode.new(params[:retain_service_given_code])
      
      respond_to do |format|
        if @retain_service_given_code.save
          flash[:notice] = 'ServiceGivenCode was successfully created.'
          format.html { redirect_to(@retain_service_given_code) }
          format.xml  { render :xml => @retain_service_given_code, :status => :created, :location => @retain_service_given_code }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @retain_service_given_code.errors, :status => :unprocessable_entity }
        end
      end
    end
    
    # PUT /retain_service_given_codes/1
    # PUT /retain_service_given_codes/1.xml
    def update
      @retain_service_given_code = Retain::ServiceGivenCode.find(params[:id])
      
      respond_to do |format|
        if @retain_service_given_code.update_attributes(params[:retain_service_given_code])
          flash[:notice] = 'ServiceGivenCode was successfully updated.'
          format.html { redirect_to(@retain_service_given_code) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @retain_service_given_code.errors, :status => :unprocessable_entity }
        end
      end
    end
    
    # DELETE /retain_service_given_codes/1
    # DELETE /retain_service_given_codes/1.xml
    def destroy
      @retain_service_given_code = Retain::ServiceGivenCode.find(params[:id])
      @retain_service_given_code.destroy
      
      respond_to do |format|
        format.html { redirect_to(retain_service_given_codes_url) }
        format.xml  { head :ok }
      end
    end
  end
end
