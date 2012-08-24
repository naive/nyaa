$:.unshift File.dirname(__FILE__) # For use/testing when no gem is installed

# stdlib
require 'open-uri'
require 'tempfile'
require 'logger'

# third party
begin
  require 'trollop'
  require 'nokogiri'
  require 'rest_client'
  require 'formatador'
rescue LoadError => e
  puts "LoadError: #{e.message}"
end

# internal
require 'nyaa/version'
require 'nyaa/constants'
require 'nyaa/torrent'
require 'nyaa/search'
require 'nyaa/download'
require 'nyaa/browser'

module Nyaa
  class << self
    attr_accessor :debug
    attr_accessor :logger

    def log(message)
      logger.debug { message }
    end
  end

  self.debug = false
  @logger ||= ::Logger.new(STDOUT)
end
