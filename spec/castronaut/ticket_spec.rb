require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))
require 'yaml'

describe Castronaut::Ticket do

  before(:all) do
    load_cas_config
  end

  describe "validating ticket granting ticket" do

    describe "when given no ticket" do

      it "has an error message explaining you must give a ticket" do
        Castronaut::Ticket.validate_ticket_granting_ticket(nil).error_message.should == 'No ticket granting ticket given'
      end

    end

    describe "when given a ticket" do

      it "attempts to find the ticket granting ticket in the database" do
        Castronaut::TicketGrantingTicket.expects(:find_by_ticket).returns(nil)
        Castronaut::Ticket.validate_ticket_granting_ticket('abc')
      end

      describe "when it finds a ticket granting ticket" do

        before do
          @ticket_granting_ticket = Castronaut::TicketGrantingTicket.new
          @ticket_granting_ticket.stubs(:username).returns('bob_smith')
          @ticket_granting_ticket.stubs(:expired?).returns(false)
          Castronaut::TicketGrantingTicket.stubs(:find_by_ticket).returns(@ticket_granting_ticket)
        end

        it "returns an error message if the ticket granting ticket is expired" do
          @ticket_granting_ticket.stubs(:expired?).returns(true)
          Castronaut::Ticket.validate_ticket_granting_ticket('abc').error_message.should == "Your session has expired. Please log in again."
        end

        it "logs a message containing the ticket and the ticket username" do
          Castronaut::Ticket.expects(:log_info).with("Ticket granting ticket [abc] for [bob_smith] successfully validated.")
          Castronaut::Ticket.validate_ticket_granting_ticket('abc')
        end

      end

      describe "when it fails to find a ticket granting ticket" do

        before do
          Castronaut::TicketGrantingTicket.stubs(:find_by_ticket).returns(nil)
        end

        it "logs a message containing the ticket and that is was not found in the database" do
          Castronaut::Ticket.expects(:log_warn).with("Ticket granting ticket [abc] was not found in the database.")
          Castronaut::Ticket.validate_ticket_granting_ticket('abc')
        end

      end

    end

    describe "in all other cases" do

      it "returns a TicketResult with no error message" do
        Castronaut::TicketGrantingTicket.stubs(:find_by_ticket).returns(nil)
        Castronaut::Ticket.validate_ticket_granting_ticket('abc').error_message.should be_nil
      end

    end

  end

end


