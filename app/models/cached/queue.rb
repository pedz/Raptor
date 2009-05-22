module Cached
  # =Retain Queue Model
  #
  # In Retain, a queue is not a real object or entity so there are
  # very few fields in the database for a queue.  The database table
  # is <em>cached_queues</em>.
  #
  # ==Fields
  #
  # <em>id - integer</em>::
  #   The key to the table.
  # <em>queue_name - character varying(6)</em>::
  #   name of the queue, e.g PTTY
  # <em>h_or_s - character varying(1)</em>::
  #   The hardware or software flag.  This corresponds to SDI field
  #   1135 and can be either 'S' or 'H' (in EBCDIC).  This designates
  #   the queue as either a "software" queue or a "hardware" queue.
  #   It appears as if a center is actually hardware or software
  #   specific but the Retain SDI calls are set up to make it appear
  #   to be an attribute of the queue.
  # <em>center_id - integer</em>::
  #   The center in which the queue lives.  This is a foreign key into
  #   the <em>cached_centers</em> table.
  # <em>created_at - timestamp without time zone</em>::
  #   Usual timestamp when db record was created.
  # <em>updated_at - timestamp without time zone</em>::
  #   Usual timestamp when db record was last updated.  As with
  #   Cached::Queues and Cached::Pmrs, this field is used to determine
  #   when Retain is queried to verify if the data cached in the
  #   database is up to date.  See <em>last_fetched</em> as well.
  # <em>dirty - boolean</em>::
  #   When it is known that the database entry is not up to date, this
  #   bit is set to true.
  # <em>last_fetched - timestamp without time zone</em>::
  #   This is the timestamp when the data from Retain caused the
  #   database record to be updated because it had changed.  To put in
  #   other words, updated_at is used to determine when to query
  #   Retain.  If the date fetched from Retain is different from the
  #   data cached in the database, then the database is updated and
  #   last_fetched is set to the current time of day.

  class Queue < Base
    set_table_name "cached_queues"
    belongs_to :center,          :class_name => "Cached::Center"
    has_many   :calls,           :class_name => "Cached::Call",      :dependent => :delete_all, :order => "slot"
    has_many   :favorite_queues, :class_name => "Cached::FavoriteQueue"
    has_many   :next_queue_pmrs, :class_name => "Cached::Pmr",       :foreign_key => "next_queue_id"
    has_many   :queue_infos,     :class_name => "Cached::QueueInfo", :foreign_key => "queue_id"
    has_many   :owners,          :through    => :queue_infos
    has_many   :psars,           :class_name => "Cached::Psar"

    def self.team_queues
      self.find(:all,
                :include => :owners,
                :order => "queue_name, h_or_s").select { |q|
        q.team_queue?
      }
    end

    def self.personal_queues
      self.find(:all,
                :include => :owners,
                :order => "queue_name, h_or_s").select { |q|
        not q.team_queue?
      }
    end

    def team_queue?
      self.owners.empty?
    end
  end
end
