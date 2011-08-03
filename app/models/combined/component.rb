# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Combined
  # === Combined Component Model
  class Component < Combined::Base
    ##
    # :attr: expire_time
    # at to 1.year
    set_expire_time 1.year

    set_db_keys :short_component_name

    add_extra_fields :multiple_rls_table_entry
    add_skipped_fields :valid, :start_date, :end_date # db fields

    set_db_constants :component_name, :release_name
  end
end
