before do
  # $cas_config.logger.info("Castronaut - handling #{request.env['REQUEST_METHOD']} #{request.env['HTTP_HOST']}#{request.env['REQUEST_URI']}") if $cas_config
end

get '/' do
  
end

get '/login' do
  no_cache
  
end

post '/login' do

end

get '/validate' do
  
end

get '/serviceValidate' do
  
end

get '/loginTicket' do
  
end

post '/loginTicket' do
  
end

private
  def no_cache
    headers 'Pragma' => 'no-cache',
            'Cache-Control' => 'no-store',
            'Expires' => (Time.now - 5.years).rfc2822
  end