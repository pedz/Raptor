# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Json
  # This predates the "Raptor 2" method.  It is a subclass of
  # Retain::RetainController although I do not really know why.  I
  # probably need to redo this at some point.
  class FavoriteQueuesController < Retain::RetainController
    def index
      favorite_queues = application_user.favorite_queues
      # favorite_queues.each do |q|
      #   async_fetch(q.queue)
      # end
      # logger.debug("favorite_queues[0].class = #{favorite_queues[0].class}")
      render :json => favorite_queues.
        to_json(:include =>
                { :queue =>
                  { :include =>
                    { :calls =>
                      { :include =>
                        { :pmr =>
                          { :include =>
                            { :center => { },
                              :customer => { },
                              :next_center => { },
                              :next_queue => { },
                              :owner => { },
                              :queue => { },
                              :resolver => { }
                            },
                            # :methods => [ :last_ct, :last_ct_time ],
                            # :except => [ :last_alter_timestamp ]
                          }
                        },
                        # :methods => [ :needs_initial_response?, :center_entry_time ],
                        :except => [ :call_search_result ]
                      },
                      :center => { },
                      :owners => { }
                    }
                  }
                })
    end

    def show
      render :json => application_user.
        favorite_queues.
        find(params[:id]).
        to_json(:include =>
                { :queue =>
                  { :include =>
                    { :calls => { :include => :pmr, :except => [ :call_search_result ]},
                      :center => { }}}})
    end
  end
end
