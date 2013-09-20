# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Retain
  module PmrsHelper
    def opc_pmr_button(binding)
      span binding, :class => 'opc-span' do |binding|
        concat(button("OPC", "$(\"opc-div\").toggleForm();"))
      end
    end

    def opc_pmr_form(binding, pmr)
      add_page_setting("opc_#{pmr.to_id}", pmr.opc)
      div(binding,
           :id => 'opc-div',
           :class => 'opc-container') do |binding|
        opc = Retain::PmrOpc.new(pmr)
        concat(render(:partial => "shared/retain/opc_form", :locals => { :opc => opc }))
      end
    end
  end
end
