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

get '/logout' do
  @presenter = Castronaut::Presenters::Logout.new(self)
  @presenter.represent!
  @presenter.your_mission.call
end

get '/serviceValidate' do
  @presenter = Castronaut::Presenters::ServiceValidate.new(self)
  @presenter.represent!
  @presenter.your_mission.call
end

get '/proxyValidate' do
  @presenter = Castronaut::Presenters::ProxyValidate.new(self)
  @presenter.represent!
  @presenter.your_mission.call
end

private
  def no_cache
    headers 'Pragma' => 'no-cache',
    'Cache-Control' => 'no-store',
    'Expires' => (Time.now - 5.years).rfc2822
  end
