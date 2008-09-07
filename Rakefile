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
  require "fileutils"
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
  Spec::Rake::SpecTask.new('coverage') do |t|
    t.spec_files = FileList['spec/**/*.rb']
    t.rcov = true
    t.rcov_opts = ['--exclude', 'spec', '--exclude', 'Library,lib/castronaut/db', '--text-report']
    t.spec_opts = ['-cfn']
  end

  desc "Run all examples"
  Spec::Rake::SpecTask.new('spec') do |t|
    t.spec_files = FileList['spec/**/*.rb']
    t.rcov = false
    t.spec_opts = ['-cfn']
  end
end

task :default => [:coverage]


namespace :ssl do

  desc "Generate a test SSL certificate for development"
  task :generate do
    FileUtils.mkdir_p('ssl') unless File.exist?('ssl')
    system("openssl req -x509 -nodes -days 365 -subj '/C=US/ST=NC/L=CH/CN=localhost' -newkey rsa:1024 -keyout ssl/devcert.pem -out ssl/devcert.pem")
  end

end


