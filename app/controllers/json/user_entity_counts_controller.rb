module Json
  class UserEntityCountsController < JsonController
    ##
    # GET /json/user_entity_counts
    # Returns a list of entities for the user with counts for the
    # number of times the user has picked the entity.
    def index
      json_send(application_user.user_entity_counts.all)
    end

    ##
    # PUT /json/user_entity_counts/:id
    # The id is actually the real name of the entity and we use the
    # user id to pick out a single UseCounter
    def update
      logger.debug("Update of #{params[:id]}")
      use_count = application_user.use_counters.find_or_create_by_name(params[:name])
      use_count.count = params[:count].to_i
      if use_count.save
        render :json => 'done'
      else
        render :json => 'failed', :status => 500
      end
    end
  end
end
