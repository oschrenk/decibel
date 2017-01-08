#!/usr/bin/env ruby -w

require 'rubygems'
require 'zip'
require 'time'
require 'tempfile'

PREFIX_LINE_COUNT = 10
MS_IN_DAY = 24 * 60 * 60 * 1000
NANO = 1000 * 1000 * 1000

def toNano(time)
  "#{'%.f0' % (time.to_f * NANO)}"
end

def putEntry(time,value)
  puts "\"#{toNano(time)}\",\"#{value}\""
end


input = ARGV[0]
NAME = 'Decibel10thData.csv'
out_path = "#{Dir.pwd}/#{NAME}"
File.delete(out_path) if File.exist?(out_path)

# Unfortunately the zip file is not created correctly
# I get "Invalid date/time in zip entry" warnings
# Turning these warnings off
Zip.warn_invalid_date = false

Zip::File.open(input) do |zipfile|
	# Find specific entry
	entry = zipfile.glob(NAME).first
	entry.extract(out_path)
	total_line_count = `wc -l "#{out_path}"`.strip.split(' ')[0].to_i - PREFIX_LINE_COUNT

  n = 0
  start_time = nil
  fraction = nil
  current_time = nil
	IO.foreach(out_path) do |line|
		n = n + 1
		if n == 1
      # eg. "Start Time: 2017/01/03, 10:50:16.920"
      date = line[12..-1].strip
      start_time = Time.strptime(date, "%Y/%m/%d,	%H:%M:%S.%L")
		elsif n == 3
      # eg. "End Time: 2017/01/03, 12:42:51.520"
      date = line[10..-1].strip
      end_time = Time.strptime(date, "%Y/%m/%d,	%H:%M:%S.%L")

      elapsed = ((end_time - start_time) * MS_IN_DAY).to_i
			fraction = elapsed.to_f / total_line_count
		elsif n == PREFIX_LINE_COUNT
      current_time = start_time
      putEntry(current_time, line.strip)
		elsif n > PREFIX_LINE_COUNT
      current_time = start_time + Rational(fraction * (n - PREFIX_LINE_COUNT), MS_IN_DAY)
      putEntry(current_time, line.strip)
		end
	end
end

