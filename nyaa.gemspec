# -*- encoding: utf-8 -*-
require File.expand_path('../lib/nyaa/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'nyaa'
  s.version     = Nyaa::VERSION
  s.homepage    = 'https://github.com/mistofvongola/nyaa'
  s.summary     = 'The nyaa gem is a CLI to NyaaTorrents.'
  s.description = 'Browse and download from NyaaTorrents from the command-line. Supports categories and filters.'

  s.authors  = ['David Palma']
  s.email    = 'david@davidpalma.me'

  s.files        = `git ls-files`.split("\n")
  s.executables  = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.require_path = ['lib']

  s.add_runtime_dependency 'formatador', '~> 0.2.3'
  s.add_runtime_dependency 'nokogiri', '~> 1.5.5'
  s.add_runtime_dependency 'rest-client', '~> 1.6.7'
end
