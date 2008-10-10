require "sinatra"

Sinatra::Application.default_options.merge!(
  :run => false,
  :env => :production                                                                   
)

require "castronaut"
run Sinatra.application
