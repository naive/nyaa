#!/usr/bin/env rake
require 'bundler/gem_tasks'
require 'rake/testtask'

task :default => :test

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

Rake::TestTask.new do |t|
  t.libs << 'lib/nyaa'
  t.test_files = FileList['test/lib/nyaa/*_test.rb']
  t.verbose = true
end

gemspec = eval(File.read(Dir["*.gemspec"].first))

desc "Validate the gemspec"
task :gemspec do
  gemspec.validate
end

desc "Build gem locally"
task :build => :gemspec do
  system "gem build #{gemspec.name}.gemspec"
  FileUtils.mkdir_p "pkg"
  FileUtils.mv "#{gemspec.name}-#{gemspec.version}.gem", "pkg"
end

desc "Install gem locally"
task :install => :build do
  system "gem install pkg/#{gemspec.name}-#{gemspec.version}"
end

desc "Clean automatically generated files"
task :clean do
  FileUtils.rm_rf "pkg"
end

desc "Publish current version of gem"
task :publish do
  system "gem push pkg/#{gemspec.name}-#{gemspec.version}.gem"
end
