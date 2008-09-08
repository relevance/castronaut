require File.dirname(__FILE__) + '/../spec_helper'

describe Castronaut::AuthenticationResult do
  
  it "exposes the given username at :username" do
    Castronaut::AuthenticationResult.new('billy').username.should == 'billy'
  end
  
  it "exposes the given message at :error_message" do
    Castronaut::AuthenticationResult.new(anything, 'my error').error_message.should == 'my error'
  end
  
  it "is valid if there is no error message" do
    Castronaut::AuthenticationResult.new(anything, nil).should be_valid
  end

  it "is invalid if there is an error message" do
    Castronaut::AuthenticationResult.new(anything, 'bad').should be_invalid
  end
end
