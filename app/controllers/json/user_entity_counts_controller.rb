module Json
  class UserEntityCountsController < JsonController
    ##
    # GET /json/user_entity_counts
    # Returns a list of entities for the user with counts for the
    # number of times the user has picked the entity.
    def index
      json_send(application_user.user_entity_counts.all)
    end
  end
end
