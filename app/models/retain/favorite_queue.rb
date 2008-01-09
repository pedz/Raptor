module Retain
  class FavoriteQueue < ActiveRecord::Base
    belongs_to :user

    # Represents the actual queue.  Fetches the "Combined" queue which
    # is a cached version of the Retain queue
    def queue
      Combined::Queue.new(:queue_name => queue_name,
                          :center => center,
                          :h_or_s => h_or_s)
    end
  end
end

###    def initialize(*args)
###      super(*args)
###      @calls = nil
###    end
###
###    # Acts like an array of calls for this queue.
###    def calls
###      return @calls if @calls
###      
###      options = { :center => center, :queue_name => queue_name, :h_or_s => 'S' }
###      queue = Retain::Queue.new(options)
###      foo = queue.calls
###      if foo.nil?
###        0
###      else
###        foo.length
###      end
###    end
