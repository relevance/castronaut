require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../vendor/sinatra/lib')
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../vendor/rack/lib')
require 'rack'
require 'sinatra'
require 'sinatra/test/unit'

Sinatra::Application.default_options.merge!(
  :env => :test,
  :run => false,
  :raise_errors => true,
  :logging => false
)

$cas_config ||= Castronaut::Configuration.new('./castronaut.example.yml')

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'app', 'config'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'app', 'controllers', 'application'))
