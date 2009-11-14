# -*- coding: utf-8 -*-

module Retain
  class CustomersController < RetainController
    def index
      @customers = Combined::Customer.find(:all, :order => :customer_number)
    end

    def show
      @customer = Combined::Customer.from_param(params[:id], signon_user)
    end

    def edit
      @customer = Combined::Customer.from_param(params[:id], signon_user)
    end

    def update
      @customer = Combined::Customer.from_param(params[:id], signon_user)
      respond_to do |format|
        if @customer.update_attributes(params[:combined_customer])
          flash[:notice] = 'Customer update was successful'
          format.html {  redirect_to(@customer) }
          format.xml  {  head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @customer.errors, :status => :unprocessable_entity }
        end
      end
    end
  end
end
