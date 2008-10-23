require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

include Castronaut::Models

describe Castronaut::Models::TicketGrantingTicket do

  it "has no proxies" do
    TicketGrantingTicket.new.proxies.should be_nil
  end

  it "has a ticket prefix of TGC" do
    TicketGrantingTicket.new.ticket_prefix.should == 'TGC'
  end

  describe "validating ticket granting ticket" do

    describe "when given no ticket" do

      it "has a message explaining you must give a ticket" do
        TicketGrantingTicket.validate_cookie(nil).message.should == 'No ticket granting ticket given'
      end
      
      it "is invalid" do
        TicketGrantingTicket.validate_cookie(nil).should be_invalid
      end
      
    end

    describe "when given a ticket" do

      it "attempts to find the ticket granting ticket in the database" do
        TicketGrantingTicket.should_receive(:find_by_ticket).and_return(nil)
        TicketGrantingTicket.validate_cookie('abc')
      end

      describe "when it finds a ticket granting ticket" do

        before do
          @ticket_granting_ticket = TicketGrantingTicket.new
          @ticket_granting_ticket.stub!(:username).and_return('bob_smith')
          @ticket_granting_ticket.stub!(:expired?).and_return(false)
          TicketGrantingTicket.stub!(:find_by_ticket).and_return(@ticket_granting_ticket)
        end

        it "returns an error message if the ticket granting ticket is expired" do
          @ticket_granting_ticket.stub!(:expired?).and_return(true)
          TicketGrantingTicket.validate_cookie('abc').message.should == "Your session has expired. Please log in again."
        end

      end

    end

    describe "in all other cases" do

      it "returns a TicketResult with no error message" do
        TicketGrantingTicket.stub!(:find_by_ticket).and_return(nil)
        TicketGrantingTicket.validate_cookie('abc').message.should be_nil
      end

    end

  end

  describe "generating for a username and client host" do

    it "delegates to :create!" do
      TicketGrantingTicket.should_receive(:create!).with(:username => 'username', :client_hostname => 'client_host')
      TicketGrantingTicket.generate_for('username', 'client_host')
    end

  end
  
  describe "general accessors" do
    
    it "returns the value of the ticket column for to_cookie" do
      tgt = TicketGrantingTicket.new
      tgt.stub!(:ticket).and_return("ticket")
      tgt.to_cookie.should == "ticket"
    end
    
    it "never expires" do
      tgt = TicketGrantingTicket.new
      tgt.expired?.should == false
    end
    
  end

end
