require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))
require 'yaml'

describe Castronaut::Presenters::Login do
  
  before(:all) do
    load_cas_config
  end
  
  before do
    @controller = mock('controller')
    @controller.stubs(:params).returns({})
    @controller.stubs(:request).returns(stub(:cookies => {}))
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
      Castronaut::Ticket.expects(:validate_ticket_granting_ticket).with('fake cookie').returns(Castronaut::TicketResult.new(stub_everything))
      Castronaut::Presenters::Login.new(@controller).validate
    end

    it "adds a notification message if you get a ticket generating ticket without error" do
      @controller.request.cookies['tgt'] = 'fake cookie'
      Castronaut::Ticket.expects(:validate_ticket_granting_ticket).with('fake cookie').returns(Castronaut::TicketResult.new(stub_everything(:username => 'Bob')))
      Castronaut::Presenters::Login.new(@controller).validate.messages.should include("You are currently logged in as Bob.  If this is not you, please log in below.")
    end

  end

  describe "when a redirection loop is intercepted" do

    it "adds a notification message" do
      @controller.params['redirection_loop_intercepted'] = 'redirect me'
      Castronaut::Presenters::Login.new(@controller).validate.messages.should include("The client and server are unable to negotiate authentication.  Please try logging in again later.")
    end

  end

  describe "when a service is present" do

    before do
      @controller.params['service'] = 'my service'
      @controller.request.cookies['tgt'] = 'tgt'
      @controller.stubs(:redirect)
      Castronaut::Ticket.expects(:validate_ticket_granting_ticket).returns(Castronaut::TicketResult.new(stub_everything(:username => 'B')))      
    end

    describe "when it is not a renewal and there is a ticket generating ticket without an error" do

      it "generates a service ticket from the service, ticket generating ticket username, and the ticket generating ticket" do
        Castronaut::Presenters::Login.any_instance.expects(:generate_service_ticket).with('my service', 'B', anything).returns(stub_everything)

        Castronaut::Presenters::Login.new(@controller).validate
      end

      it "generates a service uri ticket from the service and service ticket" do
        Castronaut::Presenters::Login.any_instance.stubs(:generate_service_ticket).with('my service', 'B', anything).returns(stub_everything)
        Castronaut::Presenters::Login.any_instance.expects(:service_uri_with_ticket).with('my service', anything).returns(stub_everything)

        Castronaut::Presenters::Login.new(@controller).validate
      end

      it "redirects to the service with ticket (status 303)" do
        Castronaut::Presenters::Login.any_instance.stubs(:generate_service_ticket).returns(stub_everything)
        Castronaut::Presenters::Login.any_instance.stubs(:service_uri_with_ticket).returns(stub_everything)

        @controller.expects(:redirect).with(anything, 303)

        Castronaut::Presenters::Login.new(@controller).validate
      end

    end

    describe "otherwise, when a gateway is present" do

      it "redirects to the service with (status 303)" do
        @controller.params['gateway'] = '1'
        @controller.expects(:redirect).with('my service', 303)

        Castronaut::Presenters::Login.new(@controller).validate
      end

    end

  end

  describe "when no service is present and a gateway is present" do

    it "adds a notification message" do
      @controller.params['service'] = nil
      @controller.params['gateway'] = '1'

      Castronaut::Presenters::Login.new(@controller).validate.messages.should include("The server cannot fulfill this gateway request because no service parameter was given.")
    end

  end
  
  describe "login ticket generation" do
    
    it "generates a login ticket at the end" do
      @controller.request.cookies['tgt'] = 'fake cookie'
      Castronaut::Presenters::Login.new(@controller).ticket_generating_ticket_cookie.should == 'fake cookie'
    end
    
  end

end
