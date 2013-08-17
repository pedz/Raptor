# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Retain
  module PmrsHelper
    def opc_pmr_button(binding)
      span binding, :class => 'pmr-opc-span' do |binding|
        concat(button("OPC", "$(\"pmr-opc-div\").togglePmrUpdateForm();"))
      end
    end

    def opc_pmr_form(binding, pmr)
      div(binding,
           :id => 'pmr-opc-div',
           :class => 'pmr-opc-container') do |binding|
        opc = Retain::PmrOpc.new(pmr)
        concat(render(:partial => "shared/retain/opc_form", :locals => { :opc => opc }))
      end
    end
  end
end
