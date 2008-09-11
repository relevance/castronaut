# Copyright 2008 Relevance Inc.
# All rights reserved

# This file may be distributed under an MIT style license.
# See MIT-LICENSE for details.

require 'rubygems'
require 'rake/gempackagetask'
require 'rake/testtask'
require 'rake/rdoctask'
require 'spec/rake/spectask'
require 'spec/rake/verify_rcov'
require "fileutils"

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


desc "Run all examples with RCov"
Spec::Rake::SpecTask.new('specs_with_rcov') do |t|
  t.spec_files = FileList['spec/**/*.rb']
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec', '--exclude', 'Library,lib/castronaut/db', '--sort', 'coverage']
  t.spec_opts = ['-cfn']
end

desc "Run all examples"
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = FileList['spec/**/*.rb']
  t.rcov = false
  t.spec_opts = ['-cfn']
end

RCov::VerifyTask.new(:verify_coverage => :specs_with_rcov) do |t|
  t.threshold = 100.0 # Make sure you have rcov 0.7 or higher!
  t.index_html = 'coverage/index.html'
end

task :default => [:verify_coverage]

namespace :ssl do

  desc "Generate a test SSL certificate for development"
  task :generate do
    FileUtils.mkdir_p('ssl') unless File.exist?('ssl')
    
    if %x{which openssl}.strip.size == 0
      puts "Unable to locate openssl, please make sure you have it installed and in your path."
    else
      system("openssl req -x509 -nodes -days 365 -subj '/C=US/ST=NC/L=CH/CN=localhost' -newkey rsa:1024 -keyout ssl/devcert.pem -out ssl/devcert.pem")
    end
  end

end
