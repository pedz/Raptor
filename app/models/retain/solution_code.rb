# -*- coding: utf-8 -*-

module Retain
  # An ActiveRecord::Base model that is initialized via the
  # AddRetainCodes migration.  These codes are used with the update
  # panel and Retain::PsarUpdate
  class SolutionCode < ActiveRecord::Base
    set_table_name "retain_solution_codes"
  end
end
