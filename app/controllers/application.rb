before do
#  $cas_config.logger.info("Castronaut - handling #{request.env['REQUEST_METHOD']} #{request.env['HTTP_HOST']}#{request.env['REQUEST_URI']}") if $cas_config
end

get '/' do
  redirect '/login'
end

get '/login' do
  no_cache

  @presenter = Castronaut::Presenters::Login.new(self)
  @presenter.validate

  erb :login, :locals => { :presenter => @presenter }
end

post '/login' do
  @presenter = Castronaut::Presenters::ProcessLogin.new(self)
  @presenter.validate
  
  # if @presenter.valid?
  #   erb :login, :locals => { :presenter => @presenter }
  # else
  #   erb :login, :locals => { :presenter => @presenter }
  # end
end

get '/validate' do
  body 'Validate-Get'
end

get '/serviceValidate' do
  body 'serviceValidate-Get'
end

get '/loginTicket' do
  body 'loginTicket-Get'
end

post '/loginTicket' do
  body 'loginTicket-Post'
end

private
  def no_cache
    headers 'Pragma' => 'no-cache',
    'Cache-Control' => 'no-store',
    'Expires' => (Time.now - 5.years).rfc2822
  end
