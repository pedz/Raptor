# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Cached
  # === Retain Component Model
  #
  # This model is the database cached version of a Retain component.
  # The database table is <em>cached_components</em>.  This is another
  # model that has not been fully flushed out.
  class Component < Cached::Base
    ##
    # :attr: id
    # The primary key for the table.

    ##
    # :attr: short_component_id
    # Not 100% sure what this is.

    ##
    # :attr: component_name
    # The text name for the component

    ##
    # :attr: multiple_change_team_id
    # Not sure what this either but it must be swell.

    ##
    # :attr: multiple_fe_support_grp_id
    # And That too!!!

    ##
    # :attr: valid
    # A Raptor database field.

    ##
    # :attr: created_at
    # Rails normal created_at timestamp that is when the db record was
    # created.

    ##
    # :attr: updated_at
    # Rails normal updated_at timestamp.  Each time the db record is
    # saved, this gets updated.

    set_table_name "cached_components"
  end
end
