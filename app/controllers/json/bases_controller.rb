# -*- coding: utf-8 -*-
module Json
  # The first AJAX request sent back by the bases request is to this
  # controller and its index method.
  class BasesController < ApplicationController
    # Returns the list of bases on the queues that have been specified
    # by the group, levels, and filter parameters.
    def index
      entities = { }

      [ :subject, :group, :levels, :filter].each do |name|
        temp = Entity.find_by_name(params[name])
        if temp.nil?
          render :json => "#{params[name]} not found", :status => 404
          return
        end
        if temp.argument_type.name != name.to_s
          render :json => "#{params[name]} has type #{temp.argument_type.name} instead of #{name}", :status => 500
          return
        end
        entities[name] = temp
      end

      logger.debug("Subject = #{entities[:subject].name}")
      case entities[:subject].name
      when 'calls'
        first_item_type_class = ::Cached::Queue

      when 'people'
        first_item_type_class = ::User
        
      else
        render :json => "base controller doesn't understand subject of #{params[:subject]}", :status => 500
        return
      end

      logger.debug("SQL => #{entities[:levels].item.condition.sql}")
      nestings = entities[:group].item.nestings.
        scoped(:conditions => { :item_type => first_item_type_class.to_s }).
        scoped(:conditions => "#{entities[:levels].item.condition.sql}")
      subject_ids = nestings.map(&:item_id).uniq
      logger.debug("Subject IDs = #{subject_ids}")

      # There may be a better way to do this but for now, I'm just
      # going to fetch the queues and then ask them to be fetched.
      first_item_type_class.find(:all, :conditions => { :id => subject_ids }).each do |q|
        async_fetch(q)
      end

      case entities[:subject].name
      when 'calls'
        subjects = ::Cached::Call.scoped(:conditions => { :queue_id => subject_ids }).
          scoped(:include => [:pmr, :queue]).scoped(:conditions => entities[:filter].item.condition.sql)
        subject_class = ::Cached::Call

      when 'people'
        subjects = ::User.scoped(:conditions => { :id => subject_ids }).
          scoped(:conditions => entities[:filter].item.condition.sql)
        subject_class ::User
      end
      last_fetched = subjects.map do |subject|
        async_fetch(subject)
        if subject.last_fetched.nil?
          1.year.ago
        else
          subject.last_fetched
        end
      end.max
      
      fresh_when(:last_modified => last_fetched, :etag => subjects)
      unless request.fresh?(response)
        render :json => {
          :class_name => subject_class.to_s,
          :subjects => subjects
        }
      end
    end
  end
end
