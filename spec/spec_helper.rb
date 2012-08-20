# encoding: utf-8
require(File.expand_path('../../lib/nyaa', __FILE__))

# Testing dependencies
gem 'minitest'
require 'minitest/autorun'
require 'turn'
require 'webmock/minitest'
require 'vcr'

#Turn.config do |c|
#  c.format = :outline
#  c.trace = true
#  c.natural = true
#end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/nyaa_casettes'
  c.hook_into :webmock
  c.default_cassette_options = { :record => :new_epsidoes }
end
