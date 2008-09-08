require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

describe Castronaut::Adapters::RestfulAuthentication do

  describe "authenticate" do
    
    it "currently is a stub and returns an authentication result" do
      Castronaut::AuthenticationResult.expects(:new)
      Castronaut::Adapters::RestfulAuthentication.authenticate('a','b','c','d')
    end
    
  end

end
