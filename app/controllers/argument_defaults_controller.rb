# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
class ArgumentDefaultsController < ApplicationController
  layout "configuration"

  # GET /argument_defaults
  # GET /argument_defaults.xml
  def index
    @argument_defaults = ArgumentDefault.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @argument_defaults }
    end
  end

  # GET /argument_defaults/1
  # GET /argument_defaults/1.xml
  def show
    @argument_default = ArgumentDefault.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @argument_default }
    end
  end

  # GET /argument_defaults/new
  # GET /argument_defaults/new.xml
  def new
    @argument_default = ArgumentDefault.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @argument_default }
    end
  end

  # GET /argument_defaults/1/edit
  def edit
    @argument_default = ArgumentDefault.find(params[:id])
  end

  # POST /argument_defaults
  # POST /argument_defaults.xml
  def create
    @argument_default = ArgumentDefault.new(params[:argument_default])

    respond_to do |format|
      if @argument_default.save
        format.html { redirect_to(@argument_default, :notice => 'ArgumentDefault was successfully created.') }
        format.xml  { render :xml => @argument_default, :status => :created, :location => @argument_default }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @argument_default.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /argument_defaults/1
  # PUT /argument_defaults/1.xml
  def update
    @argument_default = ArgumentDefault.find(params[:id])

    respond_to do |format|
      if @argument_default.update_attributes(params[:argument_default])
        format.html { redirect_to(@argument_default, :notice => 'ArgumentDefault was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @argument_default.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /argument_defaults/1
  # DELETE /argument_defaults/1.xml
  def destroy
    @argument_default = ArgumentDefault.find(params[:id])
    @argument_default.destroy

    respond_to do |format|
      format.html { redirect_to(argument_defaults_url) }
      format.xml  { head :ok }
    end
  end
end
