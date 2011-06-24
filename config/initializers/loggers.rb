# -*- coding: utf-8 -*-


require 'retain'

Retain::Base.logger = Rails.logger
Retain::Connection.logger = Rails.logger
Retain::Fields.logger = Rails.logger
Retain::Request.logger = Rails.logger
Retain::Sdi.logger = Rails.logger
Retain::SignatureLine.logger = Rails.logger
Retain::RetainError.logger = Rails.logger

require 'combined'
Combined::Base.logger = Rails.logger
Combined::AssociationProxy.logger = Rails.logger

require 'cached'
Cached::Base.logger = Rails.logger
