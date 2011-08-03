# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Retain
  # An ActiveRecord::Base model that is initialized via the
  # AddRetainCodes migration.  These codes are used with the update
  # panel and Retain::PsarUpdate
  class ServiceActionCauseTuple < ActiveRecord::Base
    set_table_name "retain_service_action_cause_tuples"
  end
end
