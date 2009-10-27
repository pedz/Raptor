# -*- coding: utf-8 -*-


require 'retain'

Retain::NO_SENDIT = File.exists?(RAILS_ROOT + "/config/no_sendit")
