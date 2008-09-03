#require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'vendor', 'sinatra', 'lib', 'sinatra'))

get '/' do
  body 'Hello world!'
end
