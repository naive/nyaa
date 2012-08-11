Gem::Specification.new do |s|
  s.name        = 'nyaa'
  s.version     = '0.1.0'
  s.homepage    = 'https://github.com/mistofvongola/nyaa'
  s.summary     = 'A simple tool to browse NyaaTorrents.'
  s.description = 'The nyaa gem is a CLI to NyaaTorrents.'

  s.authors  = ['David Palma']
  s.email    = 'requiem.der.seele@gmail.com'

  s.executables = ['nyaa']
  s.files       = `git ls-files`.split("\n")

  s.add_runtime_dependency 'trollop', '>= 1.16.2'
  s.add_runtime_dependency 'formatador', '>= 0.2.3'
  s.add_runtime_dependency 'nokogiri', '>= 1.5.5'
  s.add_runtime_dependency 'rest-client', '>= 1.6.7'
end
