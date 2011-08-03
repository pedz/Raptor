# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#


require 'combined'

Combined::DB_ONLY = File.exists?(RAILS_ROOT + "/config/db_only")
