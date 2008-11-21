require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

describe Castronaut::Presenters::ProcessLogin do

  before do
    @controller = stub('controller', :params => {}, :erb => nil, :request => stub('request', :cookies => {}, :env => { 'REMOTE_ADDR' => '10.1.1.1'}))
  end

  describe "initialization" do

    it "exposes the given controller at :controller" do
      Castronaut::Presenters::ProcessLogin.new(@controller).controller.should == @controller
    end

  end

  it "gets :service out of params['service']" do
    @controller.params['service'] = 'usefulService2'
    Castronaut::Presenters::ProcessLogin.new(@controller).service.should == 'usefulService2'
  end

  it "gets :renewal out of params['renew']" do
    @controller.params['renew'] = 'iWantToRenew'
    Castronaut::Presenters::ProcessLogin.new(@controller).renewal.should == 'iWantToRenew'
  end

  describe "gateway?" do

    it "returns true if params['gateway'] is '1'" do
      @controller.params['gateway'] = '1'
      Castronaut::Presenters::ProcessLogin.new(@controller).should be_gateway
    end

    it "returns true if params['gateway'] is 'true'" do
      @controller.params['gateway'] = 'true'
      Castronaut::Presenters::ProcessLogin.new(@controller).should be_gateway
    end

    it "returns false when anything else is passed in" do
      @controller.params['gateway'] = 'asdf'
      Castronaut::Presenters::ProcessLogin.new(@controller).should_not be_gateway
    end

  end

  it "gets :ticket_generating_ticket_cookie from request.cookies['tgt']" do
    @controller.request.cookies['tgt'] = 'fake cookie'
    Castronaut::Presenters::ProcessLogin.new(@controller).ticket_generating_ticket_cookie.should == 'fake cookie'
  end

  describe "redirection loop" do

    it "returns true when a redirection loop is passed in" do
      @controller.params['redirection_loop_intercepted'] = 'redirect'
      Castronaut::Presenters::ProcessLogin.new(@controller).redirection_loop?.should be_true
    end

    it "returns false when a redirection loop is not passed in" do
      Castronaut::Presenters::ProcessLogin.new(@controller).redirection_loop?.should be_false
    end

  end

  describe "Username" do

    it "returns the username from the params with whitespace stripped" do
      @controller.params['username'] = " Bob "
      Castronaut::Presenters::ProcessLogin.new(@controller).username.should == "Bob"
    end

  end

  describe "password" do

    it "returns the password from the params" do
      @controller.params['password'] = "password"
      Castronaut::Presenters::ProcessLogin.new(@controller).password.should == "password"
    end

  end

  describe "callbacks" do
    
    it "fires an authentication success notice" do
      process_login = Castronaut::Presenters::ProcessLogin.new(@controller)
      process_login.should_receive(:fire_notice).with('success', {})
      process_login.fire_authentication_success_notice({})
    end

    it "fires an authentication failure notice" do
      process_login = Castronaut::Presenters::ProcessLogin.new(@controller)
      process_login.should_receive(:fire_notice).with('failed', {})
      process_login.fire_authentication_failure_notice({})
    end


    describe "fire notice" do
      
      it 'does nothing if there are no callbacks' do
        Castronaut.config.stub!(:can_fire_callbacks?).and_return(false)
        process_login = Castronaut::Presenters::ProcessLogin.new(@controller)
        
        Net::HTTP::Post.should_not_receive(:new)

        process_login.fire_notice 'success', {}
      end

      it 'does nothing if there are callbacks but it can not find the requested one' do
        Castronaut.config.stub!(:can_fire_callbacks?).and_return(true)
        Castronaut.config.stub!(:callbacks).and_return({'poodles_can_fly' => 'weee.com'})

        process_login = Castronaut::Presenters::ProcessLogin.new(@controller)
        
        Net::HTTP::Post.should_not_receive(:new)

        process_login.fire_notice 'success', {}
      end


      it "parses the url using URI parse" do
        Castronaut.config.stub!(:can_fire_callbacks?).and_return(true)
        Castronaut.config.stub!(:callbacks).and_return({'on_authentication_success' => 'example.com'})
        process_login = Castronaut::Presenters::ProcessLogin.new(@controller)
        
        Net::HTTP::Post.stub!(:new).and_return(stub_everything)
        Net::HTTP.stub!(:new).and_return(stub_everything)

        URI.should_receive(:parse).with('example.com').and_return(stub_everything)

        process_login.fire_notice 'success', {}
      end

      it "builds a Net:HTTP:Post request with the given payload and status" do
        Castronaut.config.stub!(:can_fire_callbacks?).and_return(true)
        Castronaut.config.stub!(:callbacks).and_return({'on_authentication_success' => 'example.com'})
        process_login = Castronaut::Presenters::ProcessLogin.new(@controller)
        
        URI.stub!(:parse).and_return(stub('uri', 'path' => 'uri-path', 'host' => 'example.com', 'port' => '2000', 'scheme'=> 'http'))
        
        Net::HTTP::Post.should_receive(:new).with('uri-path', { "port"=>"2000"}).and_return(stub_everything)
        Net::HTTP.stub!(:new).and_return(stub_everything)

        process_login.fire_notice 'success', {}
      end

      it "sends the request using Net:HTTP.new" do
        Castronaut.config.stub!(:can_fire_callbacks?).and_return(true)
        Castronaut.config.stub!(:callbacks).and_return({'on_authentication_success' => 'example.com'})
        process_login = Castronaut::Presenters::ProcessLogin.new(@controller)
        
        Net::HTTP::Post.stub!(:new).and_return(stub_everything)
        URI.stub!(:parse).and_return(stub_everything)

        Net::HTTP.should_receive(:new).and_return(stub_everything)

        process_login.fire_notice 'success', {}
      end


    end

  end

  describe "represent!" do

    before(:each) do
      Castronaut::Models::LoginTicket.stub!(:validate_ticket).and_return(stub('login ticket', :invalid? => false))
    end
    
    describe "when the ticket validation result is invalid" do
      
      it "appends a validation failure message to the messages" do
        Castronaut::Models::LoginTicket.stub!(:validate_ticket).and_return(stub('login ticket', :invalid? => true, :message => "STUB_MESSAGE"))
        Castronaut::Presenters::ProcessLogin.new(@controller).represent!.messages.should include("STUB_MESSAGE")
      end
      
      it "generates a new login ticket from the client host" do
        Castronaut::Models::LoginTicket.stub!(:validate_ticket).and_return(stub('login ticket', :invalid? => true, :message => "STUB_MESSAGE"))
        Castronaut::Models::LoginTicket.should_receive(:generate_from).with('10.1.1.1').and_return(stub('ticket', :ticket => "STUB"))
        Castronaut::Presenters::ProcessLogin.new(@controller).represent!
      end
      
    end

    describe "when the parameters are invalid" do

      describe "when the username is blank" do

        it "appends the MissingCredentialsMessage to messages" do
          @controller.params['password'] = 'password'
          @controller.params['username'] = ''
          Castronaut::Presenters::ProcessLogin.new(@controller).represent!.messages.should include("Please supply a username and password to login.")
        end

      end

      describe "when the password is blank" do

        it "appends the MissingCredentialsMessage to messages" do
          @controller.params['password'] = ''
          @controller.params['username'] = 'username'
          Castronaut::Presenters::ProcessLogin.new(@controller).represent!.messages.should include("Please supply a username and password to login.")
        end

      end

    end

    describe "when the parameters are valid" do

      before(:each) do
        @controller.stub!(:params).and_return({ 'username' => 'username', 'password' => 'password', 'service' => ''})
      end

      it "attempts to authenticate" do
        adapter = stub_everything(:authenticate => 'result')
        Castronaut::Adapters.stub!(:selected_adapter).and_return(adapter)
        adapter.should_receive(:authenticate).with('username', 'password').and_return(stub('auth result', :valid? => false, :error_message => 'nil'))
        Castronaut::Presenters::ProcessLogin.new(@controller).represent!
      end

      describe "when authentication fails" do

        it "appends a could not authenticate message to the messages" do
          adapter = stub_everything(:authenticate => 'result')
          Castronaut::Adapters.stub!(:selected_adapter).and_return(adapter)
          adapter.stub!(:authenticate).with('username', 'password').and_return(stub('auth result', :valid? => false, :error_message => "oggie boogie"))
          Castronaut::Presenters::ProcessLogin.new(@controller).represent!.messages.should include("oggie boogie")
        end

      end

      describe "when authentication succeeds" do

        before(:each) do
          adapter = stub_everything(:authenticate => 'result')
          Castronaut::Adapters.stub!(:selected_adapter).and_return(adapter)
          adapter.stub!(:authenticate).with('username', 'password').and_return(stub_everything(:valid? => true))
          @controller.should_receive(:set_cookie)
        end

        it "generates a ticket granting ticket" do
          Castronaut::Models::TicketGrantingTicket.should_receive(:generate_for).and_return(stub_everything(:to_cookie => 'cookie'))
          Castronaut::Presenters::ProcessLogin.new(@controller).represent!
        end

        describe "when the service is blank" do

          it "appends a successful login message to the messages" do
            Castronaut::Models::TicketGrantingTicket.stub!(:generate_for).and_return(stub_everything(:to_cookie => 'cookie'))
            Castronaut::Presenters::ProcessLogin.new(@controller).represent!.messages.should include("You have successfully logged in.")
          end

        end

        describe "when the service exists" do

          before(:each) do
            @controller.stub!(:params).and_return({ 'username' => 'username', 'password' => 'password', 'service' => 'service'})
            adapter = stub_everything(:authenticate => 'result')
            Castronaut::Adapters.stub!(:selected_adapter).and_return(adapter)
            adapter.stub!(:authenticate).with('username', 'password').and_return(stub('auth result', :valid? => true))
            Castronaut::Models::TicketGrantingTicket.stub!(:generate_for).and_return(stub('ticket granting ticket', :to_cookie => 'cookie'))
          end

          it "generates a service ticket" do
            Castronaut::Models::ServiceTicket.should_receive(:generate_ticket_for).with('service', '10.1.1.1', anything)
            Castronaut::Presenters::ProcessLogin.new(@controller).represent!
          end

          describe "when the service_uri is invalid" do

            it "appends an invalid uri message to the messages" do
              Castronaut::Models::ServiceTicket.stub!(:generate_ticket_for).with('service', '10.1.1.1', anything).and_return(stub('service ticket', :service_uri => false))
              Castronaut::Presenters::ProcessLogin.new(@controller).represent!.messages.should include("The target service your browser supplied appears to be invalid. Please contact your system administrator for help.")
            end

          end

          describe "when the service_uri is valid" do

            it "redirects back to service" do
              Castronaut::Models::ServiceTicket.stub!(:generate_ticket_for).with('service', '10.1.1.1', anything).and_return(stub('service ticket', :service_uri => :service_uri_stub))
              @controller.should_receive(:redirect).with(:service_uri_stub, 303)
              process_login = Castronaut::Presenters::ProcessLogin.new(@controller)
              process_login.represent!
              process_login.instance_variable_get("@your_mission").call
            end

          end

        end

      end

    end

  end

end
