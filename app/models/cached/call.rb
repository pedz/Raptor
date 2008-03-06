module Cached
  class Call < Base
    set_table_name "cached_calls"
    belongs_to :queue, :class_name => "Cached::Queue"
    belongs_to :pmr,   :class_name => "Cached::Pmr"

    def needs_initial_response?
      if @needs_initial_response.nil?
        center = self.queue.center
        @needs_initial_response = self.pmr.signature_line_stypes('CT').all? { |sig|
          sig.center != center
        }
      end
      @needs_initial_response
    end

  end
end
