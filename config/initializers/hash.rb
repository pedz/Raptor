# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

class Hash
  class << self
    private
    def from_xml_with_colon_fixer(xml)
      fix_colon_keys(from_xml_without_colon_fixer(xml))
    end
    alias_method_chain :from_xml, :colon_fixer
  
    def fix_colon_keys(object)
      case object
      when Hash
        object.inject({ }) { |h, (k,v)| h[k.gsub(/__colon__/, ":")] = v; h }
      when Array
        object.map { |e| fix_colon_keys(e) }
      else
        object
      end
    end
  end
end

class Array
  def to_xml_with_colon_fixer(options = { }, &block)
    new_root ||= all? { |e|
      e.is_a?(first.class) && first.class.to_s != "Hash"
    } ? first.class.to_s.pluralize : "records"
    options[:root] = new_root.gsub(/:/, "__colon__")
    to_xml_without_colon_fixer(options, &block)
  end
  alias_method_chain :to_xml, :colon_fixer
end

module ActiveRecord
  class Base
    def to_xml_with_colon_fixer(options = { }, &block)
      new_root = (options[:root] || self.class).to_s.gsub(/:/, "__colon__")
      options[:root] = new_root
      to_xml_without_colon_fixer(options, &block)
    end
    alias_method_chain :to_xml, :colon_fixer
  end
end
