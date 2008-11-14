# Copyright 2008 Relevance Inc.
# All rights reserved

# This file may be distributed under an MIT style license.
# See MIT-LICENSE for details.
require 'rubygems'
require 'rake'
require 'spec/rake/spectask'
require 'spec/rake/verify_rcov'
require "fileutils"

gem :flog

CURRENT_VERSION = '0.4.4'
$package_version = CURRENT_VERSION

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
  t.threshold = 98.5
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
  threshold = 135.0

  report_path = File.expand_path(File.join(File.dirname(__FILE__), 'coverage'))
  FileUtils.mkdir_p(report_path)

  system "echo '<pre>' > #{report_path}/flog.html"
  system "flog -a app/ lib/ >> #{report_path}/flog.html" do |ok, response|
    unless ok
      puts "Flog failed with exit status: #{response.exitstatus}"
      exit 1
    end
  end

  flog_output = File.read("#{report_path}/flog.html")
  output_lines = flog_output.split("\n")

  total_score = output_lines[1].split("=").last.strip.to_f
  all_scores = output_lines.select {|line| line =~ /#/ }
  all_scores.reject { }
  total_methods = all_scores.length
  puts "Flog:"
  puts "=" * 40
  puts "  Average Score Per Method: #{total_score / total_methods}"

  top_methods = all_scores.first(3)

  threshold_failed = false

  top_methods.each_with_index do |score_with_name, index|
    score_with_name =~ /\((.*)\)/
    score = $1.to_f
    score_with_name =~ /^(.*):/
    method = $1

    puts "  #{index.next}) #{method} (#{score}) #{"(FAILED! Over threshold of #{threshold})" if score > threshold}"
    unless threshold_failed
      threshold_failed = score > threshold
    end
  end

  exit(1) if threshold_failed

  exit(0)
end

desc 'Build and install the gem'
task :gem do
  sh 'gem build castronaut.gemspec'
  sh 'sudo gem install castronaut*.gem'
end

task :default => [:verify_coverage]#, :flog]
