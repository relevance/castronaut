require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper'))

describe Castronaut::Adapters::RestfulAuthentication::User do

  describe "digest (encrypt password using salt)" do
    
    it "calls secure_digest Castronaut.cas_adapter['digest_stretches'] number of times" do
      Castronaut.config.cas_adapter['digest_stretches'] = 5
      
      Castronaut::Adapters::RestfulAuthentication::User.should_receive(:secure_digest).exactly(5).times
    
      Castronaut::Adapters::RestfulAuthentication::User.digest('password', 'salt')
    end
    
  end
  
  describe "secure digest" do
    
    it "calls Digest::SHA1.hexdigest with the flattened and joined arguments" do
      Digest::SHA1.should_receive(:hexdigest).with('20293jr--j2049j--209f3jsf--2ffndin0n')
      Castronaut::Adapters::RestfulAuthentication::User.secure_digest('20293jr', ['j2049j'], '209f3jsf', '2ffndin0n')
    end
    
  end
  
  describe "find by login" do
    
    it "attempts to the find the first user with the given login" do
      Castronaut::Adapters::RestfulAuthentication::User.should_receive(:find).with(:first, :conditions => { :login => 'bob' }).and_return(nil)
      Castronaut::Adapters::RestfulAuthentication::User.find_by_login('bob')
    end
    
    it "returns nil if no user is found with the given login" do
      Castronaut::Adapters::RestfulAuthentication::User.stub!(:find).and_return(nil)
      Castronaut::Adapters::RestfulAuthentication::User.find_by_login('bob').should be_nil
    end

    it "returns the user found with the given login" do
      Castronaut::Adapters::RestfulAuthentication::User.stub!(:find).and_return(user = stub('user'))
      Castronaut::Adapters::RestfulAuthentication::User.find_by_login('bob').should == user
    end
    
    describe "when the config has extra authentication conditions" do

      before do
        Castronaut.config.cas_adapter['extra_authentication_conditions'] = '1=2'
      end

      it "has the extra_authentication_conditions key" do
        Castronaut.config.cas_adapter.has_key?('extra_authentication_conditions').should be_true
        Castronaut::Adapters::RestfulAuthentication::User.find_by_login('bob')
      end
      
      it "attempts to find the user with the extra authentication conditions" do
        Castronaut::Adapters::RestfulAuthentication::User.should_receive(:find).with(:first, :conditions => ["login = ? AND 1=2", 'bob'])
        Castronaut::Adapters::RestfulAuthentication::User.find_by_login('bob')
      end

      it "returns the user found with the given login" do
        Castronaut::Adapters::RestfulAuthentication::User.stub!(:find).and_return(user = stub('user'))
        Castronaut::Adapters::RestfulAuthentication::User.find_by_login('bob').should == user
      end
    end

  end
  
  describe "authenticate" do
    
    it "attempts to find the user by the username / login" do
      Castronaut::Adapters::RestfulAuthentication::User.should_receive(:find_by_login).with('bob').and_return(nil)
      Castronaut::Adapters::RestfulAuthentication::User.authenticate('bob', '1234')
    end
    
    describe "when the user is not found" do
      
      it "returns a Castronaut::AuthenticationResult object with the unable to authenticate user message" do
        Castronaut::Adapters::RestfulAuthentication::User.stub!(:find_by_login).and_return(nil)
        Castronaut::Adapters::RestfulAuthentication::User.authenticate('bob', '1234').error_message.should == "Unable to authenticate the username bob"
      end
      
    end
    
    describe "when the user is found" do
      
      describe "when the credentials are invalid" do
        
        it "returns a Castronaut::AuthenticationResult object with the unable to authenticate user message" do
          Castronaut::Adapters::RestfulAuthentication::User.stub!(:find_by_login).and_return(stub(:crypted_password => "a", :salt => "b").as_null_object)
          Castronaut::Adapters::RestfulAuthentication::User.authenticate('bob', '1234').error_message.should == "Unable to authenticate the username bob"
        end
        
      end
         
      describe "when the credentials are valid" do

        it "returns a Castronaut::AuthenticationResult object with no message" do
          Castronaut::Adapters::RestfulAuthentication::User.stub!(:find_by_login).and_return(stub_model(Castronaut::Adapters::RestfulAuthentication::User, :crypted_password => "a"))
          Castronaut::Adapters::RestfulAuthentication::User.stub!(:digest).and_return("a")
          Castronaut::Adapters::RestfulAuthentication::User.authenticate('bob', '1234').error_message.should be_nil
        end
        
      end   
            
    end
    
  end

end
