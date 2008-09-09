require File.dirname(__FILE__) + '/../spec_helper'

describe Castronaut::TicketResult do
  
  it "exposes the given ticket at :ticket" do
    Castronaut::TicketResult.new('ticket').ticket.should == 'ticket'
  end
  
  it "exposes the given message at :message" do
    Castronaut::TicketResult.new('ticket', 'my error').message.should == 'my error'
  end
  
  it "exposes the given message category at :message_category" do
    Castronaut::TicketResult.new('ticket', 'my error', 'message cat').message_category.should == 'message cat'
  end
  
  describe "valid?" do

    it "negates invalid? for it's result" do
      ticket_result = Castronaut::TicketResult.new('ticket', 'msg', 'cat')
      ticket_result.stubs(:invalid?).returns(false)
      ticket_result.should be_valid
      
      ticket_result.stubs(:invalid?).returns(true)
      ticket_result.should_not be_valid
    end
  
  end
  
  describe "invalid?" do
    
    Castronaut::TicketResult::InvalidMessageCategories.each do |invalid_category|
    
      it "is invalid if the message category contains #{invalid_category}" do
        Castronaut::TicketResult.new('ticket', 'my error', "BlaBlaBla-#{invalid_category}-AlbAlbAlb").should be_invalid
      end
      
    end
    
  end
  
end
