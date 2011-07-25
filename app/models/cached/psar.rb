# -*- coding: utf-8 -*-

module Cached
  # === Retain PSAR model
  #
  # This model is the database cached version of a Retain PSAR entry.  The
  # database table is <em>cached_psars</em>.
  class Psar < Cached::Base
    ##
    # :attr: id
    # The primary key for the table.

    ##
    # :attr: pmr_id
    # The id from the cached_pmrs table for the PMR associated with
    # this PSAR.

    ##
    # :attr: apar_id
    # The id from the cached_apars table for the APAR associated with
    # this PSAR entry.  I am not sure this is set or used currently.

    ##
    # :attr: queue_id
    # The id from the cached_queues table for the queue associated
    # with the PSAR entry.  I'm not sure exactly what this is.

    ##
    # :attr: chargeable_time_hex
    # The PSAR fields are a bit hazy still in my mind.  I mostly just
    # fetch and store everything I can and try to figure out what to
    # do with it later.

    ##
    # :attr: cpu_serial_number
    # The CPU serial number probably associated with the PMR that is
    # associated with the PSAR entry.

    ##
    # :attr: cpu_type
    # The CPU type associated I'm guessing with the PMR that is
    # associated with the PSAR entry.

    ##
    # :attr: minutes_from_gmt
    # The timezone for smoething.  It is not clear to me if it is for
    # the DR that made the entry or for the customer.

    ##
    # :attr: psar_action_code
    # One part of what I call the retain_service_action_cause_tuple
    # which comes from the retain_service_action_cause_tupless table.
    # The other two parts are the psar_cause and the
    # psar_service_code.  ZTRANs is allowed to use only two of these
    # tuples but there are many others defined.  Taken by itself, I
    # haven't a clue what it means.  Taken together with the other two
    # parts, the description in the table will give a hint as to what
    # the support person did.

    ##
    # :attr: psar_activity_date
    # The date of the PSAR

    ##
    # :attr: psar_activity_stop_time
    # The stop time

    ##
    # :attr: psar_actual_time
    # The length of time spent

    ##
    # :attr: psar_cause
    # See psar_action_code

    ##
    # :attr: psar_chargeable_src_ind
    # Not sure

    ##
    # :attr: psar_chargeable_time
    # Not sure how this is different from psar_actual_time

    ##
    # :attr: psar_cia
    # Not sure

    ##
    # :attr: psar_fesn
    # The FESN is somehow connected to the component but I don't know
    # all the mysteries behind it.

    ##
    # :attr: psar_file_and_symbol
    # This is a unique identifier from Retain for a particular PSAR
    # entry.  This is used by Raptor to make sure that the entry has
    # not been altered or deleted and also to identify one PSAR entry
    # from the others.

    ##
    # :attr: psar_impact
    # The impact (usually the severity of the call at the time of the
    # entry)

    ##
    # :attr: psar_mailed_flag
    # PSARs are alterable until they are "mailed" at which time they
    # become fixed.  This flag comes from Retain and alters a bit of
    # Raptor's logic to present or not present the controls to alter
    # the PSAR.

    ##
    # :attr: psar_sequence_number
    # Hmmm... Mixed with peanut butter I'm sure it is very tasty!

    ##
    # :attr: psar_service_code
    # See psar_action_code

    ##
    # :attr: psar_solution_code
    # A sample table of these codes is in retain_solution_codes.  It
    # is such things as "Customer received relief", etc.

    ##
    # :attr: psar_stop_date_year
    # The year that the PSAR activity stopped.

    ##
    # :attr: psar_system_date
    # I'm guessing this is the actual date that the PSAR entry was
    # made but I'm not 100% sure.

    ##
    # :attr: stop_time_moc
    # This is kind of a key field.  "MOC" is minute of centry? I
    # think.

    ##
    # :attr: dirty
    # See Cached::Call#dirty.

    ##
    # :attr: created_at
    # Rails normal created_at timestamp that is when the db record was
    # created.

    ##
    # :attr: updated_at
    # Rails normal updated_at timestamp.  Each time the db record is
    # saved, this gets updated.

    ##
    # :attr: absorbed_queue_list
    # The absorbed queue list for this center... like I know what that
    # is or something.

    ##
    # :attr: registration_id
    # The id from cached_registrations of the support person who made
    # the PSAR entry.

    set_table_name "cached_psars"

    ##
    # :attr: pmr
    # A belongs_to association to the Cached::Pmr for this PSAR.
    belongs_to :pmr,          :class_name => "Cached::Pmr"

    ##
    # :attr: center
    # A belongs to association to the Cached::Center for this PSAR.
    belongs_to :center,       :class_name => "Cached::Center"

    ##
    # :attr: queue
    # A belongs to association to the Cached::Queue for this PSAR.
    belongs_to :queue,        :class_name => "Cached::Queue"

    ##
    # :attr: registration
    # A belongs_to association to the Cached::Registration for this PSAR.
    belongs_to :registration, :class_name => "Cached::Registration"

    ##
    # :attr: apar
    # There is also a belongs_to for APARs but it is not used in our
    # area so it is not hooked up yet.

    ##
    # :attr: today
    # a named scope to select today's PSAR entries (based upon the
    # calendar day).
    named_scope :today, lambda {
      {
        :conditions => { :psar_system_date => Time.now.strftime('%y%m%d') }
      }
    }

    ##
    # :attr: stop_time_range
    # A named scope to select PSARs within the range passed in.
    named_scope :stop_time_range, lambda { |range|
      { :conditions => { :psar_system_date => range } }
    }

    ##
    # Returns the stop time for the PSAR trying to take into account
    # the timezone.
    def stop_time_date
      Time.moc(stop_time_moc + minutes_from_gmt)
    end
    once :stop_time_date
    
    ##
    # Returns the stop date of the PSAR
    def stop_date
      std = stop_time_date
      Time.gm(std.year, std.month, std.day)
    end
    once :stop_date

    ##
    # A hook to call the Retain interface to delete the PSAR entry on
    # Retain before destroying it in the database.
    def before_destroy
      # The call to Retain::Psru below needs to have params come from
      # somewhere.  I don't know how to do that yet.
      return false
      options = { :operand => 'DEL ', :psar_file_and_symbol => psar_file_and_symbol }
      psru = Retain::Psru.new(options)
      begin
        psru.sendit(Retain::Fields.new)
      rescue Retain::SdiReaderError => err
        # If the guy is already gone then thats o.k.
        # logger.debug("before_destroy: SR=#{err.sr} EX=#{err.ex}")
        return (err.sr == 176 && err.ex == 510)
      end
      return true
    end
  end
end
