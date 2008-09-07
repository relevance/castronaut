require 'rubygems'

gem :rspec, '>= 1.1.4'
gem :mocha, '>= 0.9.0'
gem :activerecord, '>= 2.1.0'

require File.join(File.dirname(__FILE__), '..', 'castronaut')

Spec::Runner.configure do |config|
  config.mock_with :mocha
end
