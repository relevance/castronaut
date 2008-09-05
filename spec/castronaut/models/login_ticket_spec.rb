require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

describe Castronaut::Models::LoginTicket do

  describe "generating a new one" do
    
    it "must be given a client host" do
      Castronaut::Models::LoginTicket.generate_from("client host").should_not be_nil
    end
    
  end

end
