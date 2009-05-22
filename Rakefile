# Copyright 2008 Relevance Inc.
# All rights reserved

# This file may be distributed under an MIT style license.
# See MIT-LICENSE for details.
require 'rubygems'
require 'rake'
require 'spec/rake/spectask'
require 'spec/rake/verify_rcov'
require "fileutils"

begin
  require 'jeweler'
  files = ["MIT-LICENSE", "Rakefile", "README.textile", "castronaut.rb", "bin/castronaut"]
  files << Dir["lib/**/*", "app/**/*", "spec/**/*", "config/**/*",  "vendor/**/*"]
  
  Jeweler::Tasks.new do |s|
    s.name = "castronaut"
    s.summary = "Your friendly, cigar smoking authentication dicator... From Space!"
    s.description = "Your friendly, cigar smoking authentication dicator... From Space!"
    s.homepage = "http://github.com/relevance/castronaut"
    s.email = "aaron@thinkrelevance.com"
    s.authors = ["Relevance, Inc."]
    s.files = files.flatten
    s.require_path = 'lib'
    s.has_rdoc = false
    s.extra_rdoc_files = []
    s.rdoc_options = []
    s.bindir = 'bin'
    s.default_executable = 'castronaut'
    s.executables = ["castronaut"]    
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

desc "Run all examples with RCov"
Spec::Rake::SpecTask.new('specs_with_rcov') do |t|
  ENV["test"] = "true"
  t.spec_files = FileList['spec/**/*.rb']
  t.rcov = true
  t.rcov_opts = ['--text-report', '--exclude', "spec,Library,lib/castronaut/db,#{ENV['GEM_HOME']}", '--sort', 'coverage']
end

desc "Run all examples"
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = FileList['spec/**/*.rb']
  t.rcov = false
  t.spec_opts = ['-cfn']
end

RCov::VerifyTask.new(:verify_coverage => :specs_with_rcov) do |t|
  t.threshold = 97.0
  t.index_html = 'coverage/index.html'
end

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

task :default => [:verify_coverage]
