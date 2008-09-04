require 'rubygems'

gem :rspec, '>= 1.1.4'
gem :mocha, '>= 0.9.0'
# require 'rspec'

#ActiveRecord::Base.logger = Logger.new(STDOUT)
#ActiveRecord::Base.configurations['test'] = {  :adapter  => "sqlite3", :dbfile => 'test.db' }

require File.join(File.dirname(__FILE__), '..', 'castronaut')

Spec::Runner.configure do |config|

  config.mock_with :mocha

end

def load_cas_config
  $cas_config ||= Castronaut::Configuration.new('./castronaut.example.yml')
end
