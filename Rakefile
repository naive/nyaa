#!/usr/bin/env rake
require 'bundler/gem_tasks'
require 'rake/testtask'

task :default => :test

Rake::TestTask.new do |t|
  t.libs << 'lib/nyaa'
  t.test_files = FileList['spec/lib/nyaa/*_spec.rb']
  t.verbose = true
end

gemspec = eval(File.read(Dir["*.gemspec"].first))

desc "Validate the gemspec"
task :gemspec do
  gemspec.validate
end

task :build => :gemspec do
  system "gem build #{gemspec.name}.gemspec"
  FileUtils.mkdir_p "pkg"
  FileUtils.mv "#{gemspec.name}-#{gemspec.version}.gem", "pkg"
end

task :install => :build do
  system "gem install pkg/#{gemspec.name}-#{gemspec.version}"
end

desc "Purge the pkg directory"
task :clean do
  FileUtils.rm_rf "pkg"
end

desc "Publish gem to rubygems.org"
task :publish do
  system "gem push pkg/#{gemspec.name}-#{gemspec.version}.gem"
end
