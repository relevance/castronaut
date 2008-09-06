get '/' do
  redirect '/login'
end

get '/login' do
  no_cache

  @presenter = Castronaut::Presenters::Login.new(self)
  @presenter.represent!
  @presenter.your_mission.call
end

post '/login' do
  @presenter = Castronaut::Presenters::ProcessLogin.new(self)
  @presenter.represent!
  @presenter.your_mission.call
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
