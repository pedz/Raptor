# -*- coding: utf-8 -*-
module Json
  module Cached
    class PmrsController < Retain::RetainController
      def show
        pmr_id = params[:id]
        pmr_fields = pmr_id.split(',')
        if pmr_fields.length > 1
          problem = pmr_fields[0]
          branch = pmr_fields[1]
          if pmr_fields.length > 2
            country = pmr_fields[2]
          else
            country = '000'
          end
          hash = {
            :problem => problem,
            :branch => branch,
            :country => country
          }
          pmr = ::Cached::Pmr.find(:first, :conditions => hash)
        else
          pmr = ::Cached::Pmr.find(pmr_id)
        end
        if pmr
          render :json => pmr.to_json(:methods => [ :last_ct_time ])
        else
          render :json => "Not found".to_json, :status => 404
        end
      end
    end
  end
end
