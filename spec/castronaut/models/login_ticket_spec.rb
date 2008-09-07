require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

describe Castronaut::Models::LoginTicket do

  describe "generating from a client hostname" do
   
    it "initializes a new Login Ticket with given client hostname" do
      Castronaut::Models::LoginTicket.expects(:new).with(:client_host => 'ch').returns(stub_everything)
      Castronaut::Models::LoginTicket.generate_from('ch')
    end
    
  end

end
