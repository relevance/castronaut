# Copyright 2008 Relevance Inc.
# All rights reserved
 
# This file may be distributed under an MIT style license.
# See MIT-LICENSE for details.
 
begin
  require 'rubygems'
  require 'rake/gempackagetask'
  require 'rake/testtask'
  require 'rake/rdoctask'
  require 'spec/rake/spectask'
rescue Exception
  nil
end
 
CURRENT_VERSION = '0.1.0'
$package_version = CURRENT_VERSION
 
PKG_FILES = FileList['[A-Z]*',
'lib/**/*.rb',
'doc/**/*'
]
 
desc 'Generate documentation'
rd = Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'html'
  rdoc.template = 'doc/jamis.rb'
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Castronaut'
  rdoc.options << '--line-numbers' << '--inline-source' <<  '--main' << 'README.textile' << '--title' << 'Castronaut'
  rdoc.rdoc_files.include('README.textile', 'MIT-LICENSE', 'TODO', 'CHANGELOG')
  rdoc.rdoc_files.include('lib/**/*.rb', 'doc/**/*.rdoc')
end
 
if !defined?(Spec)
  puts "spec and cruise targets require RSpec"
else
  desc "Run all examples with RCov"
  Spec::Rake::SpecTask.new('cruise') do |t|
    t.spec_files = FileList['spec/**/*.rb']
    t.rcov = true
    t.rcov_opts = ['--exclude', 'spec', '--exclude', 'Library']
  end
 
  desc "Run all examples"
  Spec::Rake::SpecTask.new('spec') do |t|
    t.spec_files = FileList['spec/**/*.rb']
    t.rcov = false
    t.spec_opts = ['-cfs']
  end
end
 
task :default => [:spec]