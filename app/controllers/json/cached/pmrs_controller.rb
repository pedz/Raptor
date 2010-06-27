module Json
  module Cached
    class PmrsController < Retain::RetainController
      def show
        render :json => ::Cached::Pmr.find(params[:id]).to_json(:methods => [ :last_ct_time ])
      end
    end
  end
end
