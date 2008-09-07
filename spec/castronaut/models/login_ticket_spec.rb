require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

describe Castronaut::Models::LoginTicket do

  it "requires a client hostname" do
    login_ticket = Castronaut::Models::LoginTicket.new
    
    login_ticket.should_not be_valid
    login_ticket.errors.on(:client_hostname).should_not be_nil
  end

  it "requires a ticket" do
    login_ticket = Castronaut::Models::LoginTicket.new :client_hostname => 'http://example.com'
    login_ticket.stubs(:set_ticket)

    login_ticket.should_not be_valid
    login_ticket.errors.on(:ticket).should_not be_nil
  end

  describe "generating from a client hostname" do

    it "creates a new Login Ticket with given client hostname" do
      Castronaut::Models::LoginTicket.expects(:create!).with(:client_hostname => 'ch')
      Castronaut::Models::LoginTicket.generate_from('ch')
    end

  end

end
