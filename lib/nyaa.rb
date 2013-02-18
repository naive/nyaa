# -*- encoding : utf-8 -*-
$:.unshift File.dirname(__FILE__) # For use/testing when no gem is installed
# stdlib
require 'optparse'
require 'open-uri'
require 'curses'

# third party
begin
  require 'rubygems' # for ruby 1.8 compat
  require 'nokogiri'
rescue LoadError => e
  puts "LoadError: #{e.message}"
end

# internal api
require 'nyaa/version'
require 'nyaa/cli'
require 'nyaa/constants'
require 'nyaa/torrent'
require 'nyaa/search'

# internal tools
require 'nyaa/ui'
require 'nyaa/downloader'
