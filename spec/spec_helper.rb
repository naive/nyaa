# -*- encoding : utf-8 -*-
require './lib/nyaa'

# Testing dependencies
gem 'minitest'
require 'minitest/autorun'
require 'webmock/minitest'
require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'fixtures/nyaa_casettes'
  c.hook_into :webmock
  c.default_cassette_options = { :record => :new_epsidoes }
end
