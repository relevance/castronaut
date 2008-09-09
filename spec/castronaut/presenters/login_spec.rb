require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

describe Castronaut::Presenters::Login do
  
  before do
    @controller = mock('controller')
    @controller.stubs(:params).returns({ })
    @controller.stubs(:request).returns(stub(:cookies => {}, :env => { 'REMOTE_ADDR' => '10.1.1.1' }))
    @controller.stubs(:erb)
  end

  describe "initialization" do

    it "exposes the given controller at :controller" do
      Castronaut::Presenters::Login.new(@controller).controller.should == @controller
    end

  end

  it "gets :service out of params['service']" do
    @controller.params['service'] = 'usefulService2'
    Castronaut::Presenters::Login.new(@controller).service.should == 'usefulService2'
  end

  it "gets :renewal out of params['renew']" do
    @controller.params['renew'] = 'iWantToRenew'
    Castronaut::Presenters::Login.new(@controller).renewal.should == 'iWantToRenew'
  end

  describe "gateway?" do

    it "returns true if params['gateway'] is '1'" do
      @controller.params['gateway'] = '1'
      Castronaut::Presenters::Login.new(@controller).should be_gateway
    end

    it "returns true if params['gateway'] is 'true'" do
      @controller.params['gateway'] = 'true'
      Castronaut::Presenters::Login.new(@controller).should be_gateway
    end

  end

  it "gets :ticket_generating_ticket_cookie from request.cookies['tgt']" do
    @controller.request.cookies['tgt'] = 'fake cookie'
    Castronaut::Presenters::Login.new(@controller).ticket_generating_ticket_cookie.should == 'fake cookie'
  end

  describe "when the ticket generating ticket cookie is present" do

    it "validates the ticket generating ticket" do
      @controller.request.cookies['tgt'] = 'fake cookie'
      Castronaut::Models::TicketGrantingTicket.expects(:validate_cookie).with('fake cookie').returns(Castronaut::TicketResult.new(stub_everything))
      Castronaut::Presenters::Login.new(@controller).represent!
    end

    it "adds a notification message if you get a ticket generating ticket without error" do
      @controller.request.cookies['tgt'] = 'fake cookie'
      Castronaut::Models::TicketGrantingTicket.expects(:validate_cookie).with('fake cookie').returns(Castronaut::TicketResult.new(stub_everything(:username => 'Bob')))
      Castronaut::Presenters::Login.new(@controller).represent!.messages.should include("You are currently logged in as Bob.  If this is not you, please log in below.")
    end

  end

  describe "when a redirection loop is intercepted" do

    it "adds a notification message" do
      @controller.params['redirection_loop_intercepted'] = 'redirect me'
      Castronaut::Presenters::Login.new(@controller).represent!.messages.should include("The client and server are unable to negotiate authentication.  Please try logging in again later.")
    end

  end

  describe "when a service is present" do

    before do
      @controller.params['service'] = 'http://example.com'
      @controller.request.cookies['tgt'] = 'tgt'
      @controller.stubs(:redirect)
      @ticket_granting_ticket_result = Castronaut::TicketResult.new(Castronaut::Models::TicketGrantingTicket.new(:username => 'B'))
      Castronaut::Models::TicketGrantingTicket.stubs(:validate_cookie).returns(@ticket_granting_ticket_result)
    end

    describe "when it is not a renewal and there is a ticket granting ticket without an error" do

      it "generates a service ticket from the service, client hostname, and ticket generating ticket" do
        Castronaut::Models::ServiceTicket.expects(:generate_ticket_for).with('http://example.com', '10.1.1.1', @ticket_granting_ticket_result.ticket).returns(Castronaut::Models::ServiceTicket.new)

        Castronaut::Presenters::Login.new(@controller).represent!
      end

      it "redirects to the service uri(status 303)" do
        service_ticket = Castronaut::Models::ServiceTicket.new(:service => 'http://example.com')
        service_ticket.stubs(:service_uri).returns('http://example.com')
        
        Castronaut::Models::ServiceTicket.stubs(:generate_ticket_for).returns(service_ticket)
        
        @controller.expects(:redirect).with('http://example.com', 303)

        Castronaut::Presenters::Login.new(@controller).represent!
      end

    end

    describe "otherwise, when a gateway is present" do

      it "redirects to the service with (status 303)" do
        @controller.params['gateway'] = '1'
        @controller.expects(:redirect).with('http://example.com', 303)
        service_ticket = Castronaut::Models::ServiceTicket.new
        service_ticket.service = 'http://example.com'

        Castronaut::Models::ServiceTicket.stubs(:generate_ticket_for).returns(service_ticket)
        service_ticket.stubs(:service_uri).returns('http://example.com')
          
        Castronaut::Presenters::Login.new(@controller).represent!
      end

    end

    describe "when the service uri is not a valid uri" do
      
       it "adds a warning message for the user" do
        service_ticket = Castronaut::Models::ServiceTicket.new
        service_ticket.service = 'pickles'
        service_ticket.expects(:service_uri).returns(nil)
        Castronaut::Models::ServiceTicket.stubs(:generate_ticket_for).with('http://example.com', '10.1.1.1', anything).returns(service_ticket)

        Castronaut::Presenters::Login.new(@controller).represent!.messages.should include("The target service your browser supplied appears to be invalid. Please contact your system administrator for help.")
      end
      
    end
  end

  describe "when no service is present and a gateway is present" do

    it "adds a notification message" do
      @controller.params['service'] = nil
      @controller.params['gateway'] = '1'

      Castronaut::Presenters::Login.new(@controller).represent!.messages.should include("The server cannot fulfill this gateway request because no service parameter was given.")
    end

  end
  
  describe "login ticket generation" do
    
     it "generates a new login ticket when you call :login_ticket" do
       Castronaut::Models::LoginTicket.expects(:generate_from).returns(stub_everything(:ticket => 'ticket'))
       Castronaut::Presenters::Login.new(@controller).login_ticket
     end

  end

end
