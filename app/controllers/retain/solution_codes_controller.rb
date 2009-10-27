# -*- coding: utf-8 -*-

module Retain
  class SolutionCodesController < ApplicationController
    # GET /retain_solution_codes
    # GET /retain_solution_codes.xml
    def index
      @retain_solution_codes = Retain::SolutionCode.find(:all)
      
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @retain_solution_codes }
      end
    end
    
    # GET /retain_solution_codes/1
    # GET /retain_solution_codes/1.xml
    def show
      @retain_solution_code = Retain::SolutionCode.find(params[:id])
      
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @retain_solution_code }
      end
    end
    
    # GET /retain_solution_codes/new
    # GET /retain_solution_codes/new.xml
    def new
      @retain_solution_code = Retain::SolutionCode.new
      
      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @retain_solution_code }
      end
    end
    
    # GET /retain_solution_codes/1/edit
    def edit
      @retain_solution_code = Retain::SolutionCode.find(params[:id])
    end
    
    # POST /retain_solution_codes
    # POST /retain_solution_codes.xml
    def create
      @retain_solution_code = Retain::SolutionCode.new(params[:retain_solution_code])
      
      respond_to do |format|
        if @retain_solution_code.save
          flash[:notice] = 'SolutionCode was successfully created.'
          format.html { redirect_to(@retain_solution_code) }
          format.xml  { render :xml => @retain_solution_code, :status => :created, :location => @retain_solution_code }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @retain_solution_code.errors, :status => :unprocessable_entity }
        end
      end
    end
    
    # PUT /retain_solution_codes/1
    # PUT /retain_solution_codes/1.xml
    def update
      @retain_solution_code = Retain::SolutionCode.find(params[:id])
      
      respond_to do |format|
        if @retain_solution_code.update_attributes(params[:retain_solution_code])
          flash[:notice] = 'SolutionCode was successfully updated.'
          format.html { redirect_to(@retain_solution_code) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @retain_solution_code.errors, :status => :unprocessable_entity }
        end
      end
    end
    
    # DELETE /retain_solution_codes/1
    # DELETE /retain_solution_codes/1.xml
    def destroy
      @retain_solution_code = Retain::SolutionCode.find(params[:id])
      @retain_solution_code.destroy
      
      respond_to do |format|
        format.html { redirect_to(retain_solution_codes_url) }
        format.xml  { head :ok }
      end
    end
  end
  
end
