require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))
include Castronaut::Models

describe Castronaut::Models::LoginTicket do
  
  it "has no username" do
    LoginTicket.new.username.should be_nil
  end

  it "has no proxies" do
    LoginTicket.new.proxies.should be_nil
  end
  
  it "has a ticket prefix of LT" do
    LoginTicket.new.ticket_prefix.should == 'LT'
  end
  
  it "requires a client hostname" do
    login_ticket = LoginTicket.new
    
    login_ticket.should_not be_valid
    login_ticket.errors.on(:client_hostname).should_not be_nil
  end

  it "requires a ticket" do
    login_ticket = LoginTicket.new :client_hostname => 'http://example.com'
    login_ticket.stub!(:dispense_ticket)

    login_ticket.should_not be_valid
    login_ticket.errors.on(:ticket).should_not be_nil
  end

  describe "generating from a client hostname" do

    it "creates a new Login Ticket with given client hostname" do
      LoginTicket.should_receive(:create!).with(:client_hostname => 'ch')
      LoginTicket.generate_from('ch')
    end

  end
  
  describe "validating a ticket" do
    
    describe "when the ticket is missing" do
      
      it "returns a ticket result with the MissingMessage" do
        Castronaut::TicketResult.should_receive(:new).with(nil, LoginTicket::MissingMessage)
        LoginTicket.validate_ticket(nil)
      end
      
    end
    
    it "attempts to the find the login ticket using the given ticket" do
      LoginTicket.should_receive(:find_by_ticket).with("ticket").and_return(nil)
      LoginTicket.validate_ticket("ticket")
    end
    
    describe "when the ticket is invalid" do
      
      it "returns a ticket result with the InvalidMessage" do
        Castronaut::TicketResult.should_receive(:new).with(nil, LoginTicket::InvalidMessage)
        LoginTicket.stub!(:find_by_ticket).and_return(nil)
        LoginTicket.validate_ticket("ticket")
      end
      
    end
    
    describe "when the ticket is valid" do
      
      describe "and it has already been consumed" do
        
        it "returns a ticket result with the AlreadyConsumedMessage" do
          login_ticket = stub_everything(:consumed? => true)
          
          Castronaut::TicketResult.should_receive(:new).with(login_ticket, LoginTicket::AlreadyConsumedMessage)
          LoginTicket.stub!(:find_by_ticket).and_return(login_ticket)
          LoginTicket.validate_ticket("ticket")
        end
        
      end
      
      describe "and it has already expired" do
        
        it "returns a ticket result with the ExpiredMessage" do
          login_ticket = stub_model(LoginTicket, :expired? => true, :consumed? => false)
          LoginTicket.stub!(:find_by_ticket).and_return(login_ticket)
          
          Castronaut::TicketResult.should_receive(:new).with(login_ticket, LoginTicket::ExpiredMessage)
          LoginTicket.validate_ticket("ticket")
        end
        
      end
      
      it "consumes the ticket" do
        login_ticket = stub_model(LoginTicket, :expired? => false, :consumed? => false)
        login_ticket.should_receive(:consume!)
        
        LoginTicket.stub!(:find_by_ticket).and_return(login_ticket)

        LoginTicket.validate_ticket("ticket")
      end
      
    end
    
  end

end
