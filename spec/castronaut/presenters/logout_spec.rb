require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

describe Castronaut::Presenters::Logout do
  
  before do
    @controller = stub('controller', :params => {}, :erb => nil, :request => stub('request', :cookies => {}, :env => { 'REMOTE_ADDR' => '10.1.1.1'}), :response => stub({}))
  end

  describe "initialization" do

    it "exposes the given controller at :controller" do
      Castronaut::Presenters::Logout.new(@controller).controller.should == @controller
    end

  end

  it "gets :ticket_granting_ticket_cookie from request.cookies['tgt']" do
    @controller.request.cookies['tgt'] = 'fake cookie'
    Castronaut::Presenters::Logout.new(@controller).ticket_granting_ticket_cookie.should == 'fake cookie'
  end
  
  it "gets :client_host from request.env" do
    Castronaut::Presenters::Logout.new(@controller).client_host.should == '10.1.1.1'
  end

  it "generates a new login ticket when you call :login_ticket" do
    Castronaut::Models::LoginTicket.should_receive(:generate_from).and_return(stub(:ticket => 'ticket').as_null_object)
    Castronaut::Presenters::Logout.new(@controller).login_ticket
  end

  describe "representing" do
    
    before { @controller.response.stub!(:delete_cookie) }

    it "attempts to find the ticket granting ticket using the ticket granting ticket cookie" do
      Castronaut::Models::TicketGrantingTicket.should_receive(:find_by_ticket).and_return(nil)
      Castronaut::Presenters::Logout.new(@controller).represent!
    end
    
    it "deletes the ticket granting ticket cookie" do
      @controller.request.cookies['tgt'] = 'fake cookie'
      Castronaut::Models::TicketGrantingTicket.stub!(:find_by_ticket)
      @controller.request.cookies.should_receive(:delete).with('tgt')

      Castronaut::Presenters::Logout.new(@controller).represent!
    end

    describe "when a ticket granting ticket is found" do
      
      it "cleans up any proxy granting tickets for the ticket granting tickets username" do
        Castronaut::Models::TicketGrantingTicket.stub!(:find_by_ticket).and_return(stub_model(Castronaut::Models::TicketGrantingTicket, :destroy => nil))

        Castronaut::Models::ProxyGrantingTicket.should_receive(:clean_up_proxy_granting_tickets_for)

        Castronaut::Presenters::Logout.new(@controller).represent!
      end

      it "destroys the ticket granting ticket" do
        ticket_granting_ticket = stub_model(Castronaut::Models::TicketGrantingTicket)
        ticket_granting_ticket.should_receive(:destroy) 

        Castronaut::Models::TicketGrantingTicket.stub!(:find_by_ticket).and_return(ticket_granting_ticket)

        Castronaut::Models::ProxyGrantingTicket.stub!(:clean_up_proxy_granting_tickets_for)

        Castronaut::Presenters::Logout.new(@controller).represent!
      end

    end

    it "sets a successfully logged out message" do
      @controller.request.cookies['tgt'] = 'fake cookie'
      Castronaut::Models::TicketGrantingTicket.stub!(:find_by_ticket)

      Castronaut::Presenters::Logout.new(@controller).represent!.messages.should include("You have successfully logged out.")
    end

    it "deletes the tgt cookie from the controller" do
      @controller.response.should_receive(:delete_cookie).with('tgt')
      Castronaut::Presenters::Logout.new(@controller).represent!
    end
    
  end
end

