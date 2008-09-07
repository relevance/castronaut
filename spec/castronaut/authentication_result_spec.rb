require File.dirname(__FILE__) + '/../spec_helper'

describe Castronaut::AuthenticationResult do
  
  before(:all) do
    load_cas_config
  end
  
  it "exposes the given username at :username" do
    Castronaut::AuthenticationResult.new('billy', anything, anything).username.should == 'billy'
  end
  
  it "exposes the given service at :service" do
    Castronaut::AuthenticationResult.new(anything, 'http://service', anything).service.should == 'http://service'
  end

  it "exposes the given environment at :environment" do
    Castronaut::AuthenticationResult.new(anything, anything, 'env').environment.should == 'env'
  end

  it "exposes the given message at :error_message" do
    Castronaut::AuthenticationResult.new(anything, anything, anything, 'my error').error_message.should == 'my error'
  end
  
  it "is valid if there is no error message" do
    Castronaut::AuthenticationResult.new(anything, anything, anything, nil).should be_valid
  end

  it "is invalid if there is an error message" do
    Castronaut::AuthenticationResult.new(anything, anything, anything, 'bad').should be_invalid
  end
end
