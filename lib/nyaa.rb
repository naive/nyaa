# -*- encoding : utf-8 -*-
$:.unshift File.dirname(__FILE__) # For use/testing when no gem is installed
# stdlib
require 'open-uri'
require 'tempfile'

# third party
begin
  require 'trollop'
  require 'nokogiri'
  require 'rest_client'
  require 'formatador'
rescue LoadError => e
  puts "LoadError: #{e.message}"
end

# internal api
require 'nyaa/version'
require 'nyaa/constants'
require 'nyaa/torrent'
require 'nyaa/search'

# internal tools
require 'nyaa/browser'
require 'nyaa/downloader'
