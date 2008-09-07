require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

describe Castronaut::Models::LoginTicket do

  describe "generating from a client hostname" do
    
    before(:all) do
      LT = Castronaut::Models::LoginTicket
    end

    it "initializes a new Login Ticket with given client hostname" do
      LT.expects(:new).with(:client_hostname => 'ch').returns(stub_everything)
      LT.generate_from('ch')
    end

    
  end

end
