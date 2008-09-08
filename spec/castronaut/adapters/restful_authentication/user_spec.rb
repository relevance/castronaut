require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper'))

describe Castronaut::Adapters::RestfulAuthentication::User do

  describe "digest (encrypt password using salt)" do
    
    it "calls secure_digest Castronaut.cas_adapter['digest_stretches'] number of times" do
      Castronaut.config.cas_adapter['digest_stretches'] = 5
      
      Castronaut::Adapters::RestfulAuthentication::User.expects(:secure_digest).times(5)
    
      Castronaut::Adapters::RestfulAuthentication::User.digest('password', 'salt')
    end
    
  end
  
  describe "secure digest" do
    
    it "calls Digest::SHA1.hexdigest with the flattened and joined arguments" do
      Digest::SHA1.expects(:hexdigest).with('20293jr--j2049j--209f3jsf--2ffndin0n')
      Castronaut::Adapters::RestfulAuthentication::User.secure_digest('20293jr', ['j2049j'], '209f3jsf', '2ffndin0n')
    end
    
  end
  
  describe "authenticate" do
    
    it "attempts to find the user by the username / login" do
      Castronaut::Adapters::RestfulAuthentication::User.expects(:find_by_login).with('bob').returns(nil)
      Castronaut::Adapters::RestfulAuthentication::User.authenticate('bob', '1234')
    end
    
    describe "when the user is not found" do
      
      it "returns a Castronaut::AuthenticationResult object with the unable to authenticate user message" do
        Castronaut::Adapters::RestfulAuthentication::User.stubs(:find_by_login).returns(nil)
        Castronaut::Adapters::RestfulAuthentication::User.authenticate('bob', '1234').error_message.should == "Unable to authenticate the username bob"
      end
      
    end
    
    describe "when the user is found" do
      
      describe "when the credentials are invalid" do
        
        it "returns a Castronaut::AuthenticationResult object with the unable to authenticate user message" do
          Castronaut::Adapters::RestfulAuthentication::User.stubs(:find_by_login).returns(stub_everything(:crypted_password => "a", :salt => "b"))
          Castronaut::Adapters::RestfulAuthentication::User.authenticate('bob', '1234').error_message.should == "Unable to authenticate the username bob"
        end
        
      end
         
      describe "when the credentials are valid" do

        it "returns a Castronaut::AuthenticationResult object with no message" do
          Castronaut::Adapters::RestfulAuthentication::User.stubs(:find_by_login).returns(stub_everything(:crypted_password => "a"))
          Castronaut::Adapters::RestfulAuthentication::User.stubs(:digest).returns("a")
          Castronaut::Adapters::RestfulAuthentication::User.authenticate('bob', '1234').error_message.should be_nil
        end
        
      end   
            
    end
    
  end

end
