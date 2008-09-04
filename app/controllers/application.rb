before do
#  $cas_config.logger.info("Castronaut - handling #{request.env['REQUEST_METHOD']} #{request.env['HTTP_HOST']}#{request.env['REQUEST_URI']}") if $cas_config
end

get '/' do
  redirect '/login'
end

get '/login' do
  no_cache
  
  @service = params['service']
  @renewal = params['renew']
  @gateway = ['1', 'true'].include?(params['gateway'])
  
  if tgt_cookie = request.cookies['tgt']
    ticket_generating_ticket, ticket_generating_ticket_error = validate_ticket_granting_ticket(tgt_cookie)
    
    if ticket_generating_ticket && !ticket_generating_ticket_error
      @message = "You are currently logged in as #{ticket_generating_ticket.username}.  If this is not you, please log in below."
    end
  end
  
  if params['redirection_loop_intercepted']
    @message = 'The client and server are unable to negotiate authentication.  Please try logging in again later.'
  end
  
  erb :login, 
      :locals => { :message => @message }      
      
end

post '/login' do
  body 'Login-Post'
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
