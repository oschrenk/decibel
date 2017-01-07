#!/usr/bin/env ruby -w

require 'rubygems'
require 'zip'
require 'date'
require 'tempfile'

PREFIX_LINE_COUNT = 10
MS = 24 * 60 * 60 * 1000

zipFile = ARGV[0]
NAME = 'Decibel10thData.csv'
out_path = "#{Dir.pwd}/#{NAME}"
File.delete(out_path) if File.exist?(out_path)

# Unfortunately the zip file is not created correctly
# I get "Invalid date/time in zip entry" warnings
# Turning these warnings off
Zip.warn_invalid_date = false

Zip::File.open(zipFile) do |zipfile|
	# Find specific entry
	entry = zipfile.glob(NAME).first
	puts "Extracting #{entry.name} to #{out_path}"
	entry.extract(out_path)
	total_line_count = `wc -l "#{out_path}"`.strip.split(' ')[0].to_i - PREFIX_LINE_COUNT

  n = 0
  start_time = nil
  fraction = nil
  current_time = nil
	IO.foreach(out_path) do |line|
		n = n + 1
		if n == 1
			puts "Parsing #{line}"
      # eg. "Start Time: 2017/01/03, 10:50:16.920"
      date = line[12..-1].strip
      start_time = DateTime.strptime(date, "%Y/%m/%d,	%H:%M:%S.%L")
		elsif n == 3
			puts "Parsing #{line}"
      # eg. "End Time: 2017/01/03, 12:42:51.520"
      date = line[10..-1].strip
      end_time = DateTime.strptime(date, "%Y/%m/%d,	%H:%M:%S.%L")

      elapsed = ((end_time - start_time) * MS).to_i
			fraction = elapsed.to_f / total_line_count

			puts "#{total_line_count} entries in #{elapsed} milliseconds"
      puts "That is one entry every #{fraction} millisecond"
		elsif n == PREFIX_LINE_COUNT
      current_time = start_time
      puts "\"#{current_time.iso8601(6)}\",\"#{line.strip}\""
		elsif n > PREFIX_LINE_COUNT
      current_time = start_time + Rational(fraction * (n - PREFIX_LINE_COUNT), MS)
      puts "\"#{current_time.iso8601(6)}\",\"#{line.strip}\""
		end
	end
end

