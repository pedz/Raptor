module Retain
  class FavoriteQueue < ActiveRecord::Base
    belongs_to :user
    
    def calls
      options = { :center => center, :queue_name => queue_name, :h_or_s => 'S' }
      queue = Retain::Queue.new(options)
      foo = queue.calls
      if foo.nil?
        0
      else
        foo.length
      end
    end
  end
end
