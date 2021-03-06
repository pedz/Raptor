# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module HotPmrListsHelper
  def action_taken_date(pmr)
    if text_line = pmr.ecpaat_signature["Action Taken"]
      signature = Retain::SignatureLine.new(text_line.text)
      signature.date.strftime("%b %d, %Y %H:%M")
    else
      ""
    end
  end

  def action_plan_date(pmr)
    if text_line = pmr.ecpaat_signature["Action Plan"]
      signature = Retain::SignatureLine.new(text_line.text)
      signature.date.strftime("%b %d, %Y %H:%M")
    else
      ""
    end
  end

  def pmr_severity(pmr)
    if (c = pmr.primary_call) && c.severity
      c.severity
    else
      pmr.severity
    end
  end
  
  def safe_customer_name(pmr)
    if pmr.customer
      pmr.customer.company_name
    else
      "Company Name not cached in Raptor"
    end
  end

  def problem_lines(pmr)
    if pmr.ecpaat["Problem"]
      pmr.ecpaat["Problem"]
    else
      []
    end
  end

  def action_taken_lines(pmr)
    if pmr.ecpaat["Action Taken"]
      pmr.ecpaat["Action Taken"]
    else
      []
    end
  end

  def action_plan_lines(pmr)
    if pmr.ecpaat["Action Plan"]
      pmr.ecpaat["Action Plan"]
    else
      []
    end
  end

  def contact_lines(pmr)
    lines = []
    if owner = pmr.owner
      lines << "Owner: #{owner.name}"
    end
    if resolver = pmr.resolver
      lines << "Resolver: #{resolver.name}"
    end
    if (primary = pmr.primary_call) &&
        (queue = primary.queue) &&
        ((primary_owners = queue.owners).length > 0)
      lines << "Primary owner: #{primary_owners[0].name}"
    end
    lines
  end
end
