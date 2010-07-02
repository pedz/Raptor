module Json
  class FavoriteQueuesController < Retain::RetainController
    def index
      render :json => application_user.favorite_queues
    end
  end
end
