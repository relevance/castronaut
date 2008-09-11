# Copyright 2008 Relevance Inc.
# All rights reserved

# This file may be distributed under an MIT style license.
# See MIT-LICENSE for details.
require 'rubygems'
require 'rake'
require 'spec/rake/spectask'
require 'spec/rake/verify_rcov'
require "fileutils"

CURRENT_VERSION = '0.1.0'
$package_version = CURRENT_VERSION

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
  t.threshold = 100.0
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

desc "Flog the code, keeping things under control by using a threshold"
task :flog do
  flog_report = "coverage/flog"
  
  threshold = 10.27
  `flog app lib 2>/dev/null 1>#{flog_report}`
  result = IO.popen('cat ' + 
                     flog_report + 
                     ' | grep "(" ' +
                     ' | grep -v "main#none" | head -n 1'
                    ).readlines.join('')
  result =~ /\((.*)\)/
  flog = $1.to_f
  result =~ /^(.*):/
  method = $1
  
  if flog > threshold
    puts "FLOG failed for #{method} with score of #{flog} (threshold is #{threshold})."
    exit(0)
  end  
  
  puts "FLOG passed with highest score being #{flog} for #{method} (threshold is #{threshold})."
  exit(1)
end

task :default => [:verify_coverage, :flog]
