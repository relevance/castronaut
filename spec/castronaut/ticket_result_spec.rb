require File.dirname(__FILE__) + '/../spec_helper'

describe Castronaut::TicketResult do
  
  it "exposes the given ticket at :ticket" do
    Castronaut::TicketResult.new('ticket').ticket.should == 'ticket'
  end
  
  it "exposes the given message at :error_message" do
    Castronaut::TicketResult.new('ticket', 'my error').error_message.should == 'my error'
  end
  
  it "is valid if there is no error message" do
    Castronaut::TicketResult.new('ticket', nil).should be_valid
  end

end
