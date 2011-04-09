#!/usr/bin/env ruby

#!/usr/bin/ruby

require 'rubygems'
require 'spreadsheet'

Spreadsheet.client_encoding = 'UTF-8'
book = Spreadsheet.open ARGV[0]
sheet = book.worksheet 0

cmt = Regexp.new('CMT #')
pmrs = Regexp.new('PMRS')
state = :new
rnum = 0
column = nil

sheet.each do |row|
  rnum += 1
  case state
  when :new
    if cmt.match(row[0])
      row.each_index { |index| column = index if pmrs.match(row[index]) }
      state = :going
    end

  when :going
    next if row[column].nil?
    pmr_pieces = row[column].split(',')
    pmrs = (0 ... (pmr_pieces.length / 3)).inject([]) do |memo, index|
      i = index * 3
      pmr = pmr_pieces[i] + "," + pmr_pieces[i + 1] + "," + pmr_pieces[i + 2]
      memo << pmr
    end
    puts "#{row[0]}: #{pmrs.join(' ')}"
  end
end
