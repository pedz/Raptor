#!/usr/bin/env ruby
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
# -*- coding: utf-8 -*-

require 'rubygems'
require 'spreadsheet'

Spreadsheet.client_encoding = 'UTF-8'
book = Spreadsheet.open ARGV[0]
sheet = book.worksheet 0

cmt = Regexp.new('CMT #')
pmrs = Regexp.new('PMRS')
state = :new
rnum = 0
crit_column = nil
pmr_column = nil

sheet.each do |row|
  rnum += 1
  case state
  when :new
    ( 0 .. 9 ).each do |i|
      if cmt.match(row[i])
        crit_column = i
	row.each_index { |index| pmr_column = index if pmrs.match(row[index]) }
	state = :going
      end
    end

  when :going
    next if row[pmr_column].nil?
    pmr_pieces = row[pmr_column].split(',')
    pmrs = (0 ... (pmr_pieces.length / 3)).inject([]) do |memo, index|
      i = index * 3
      pmr = pmr_pieces[i] + "," + pmr_pieces[i + 1] + "," + pmr_pieces[i + 2]
      memo << pmr
    end
    puts "#{row[crit_column]}: #{pmrs.join(' ')}"
  end
end

