require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper'))

describe Castronaut::Adapters::Development::User do

  describe "find by login" do
    
    it "attempts to the find the first user with the given login" do
      Castronaut::Adapters::Development::User.should_receive(:find_by_login).and_return(nil)
      Castronaut::Adapters::Development::User.find_by_login('bob')
    end
    
    it "returns nil if no user is found with the given login" do
      Castronaut::Adapters::Development::User.stub!(:find).and_return(nil)
      Castronaut::Adapters::Development::User.find_by_login('bob').should be_nil
    end

    it "returns the user found with the given login" do
      Castronaut::Adapters::Development::User.stub!(:find_by_login).and_return(user = stub('user'))
      Castronaut::Adapters::Development::User.find_by_login('bob').should == user
    end
    
  end
  
  describe "authenticate" do
    
    it "attempts to find the user by the username / login" do
      Castronaut::Adapters::Development::User.should_receive(:find_by_login).with('bob').and_return(nil)
      Castronaut::Adapters::Development::User.authenticate('bob', '1234')
    end
    
    describe "when the user is not found" do
      
      it "returns a Castronaut::AuthenticationResult object with the unable to authenticate user message" do
        Castronaut::Adapters::Development::User.stub!(:find_by_login).and_return(nil)
        Castronaut::Adapters::Development::User.authenticate('bob', '1234').error_message.should == "Unable to authenticate the username bob"
      end
      
    end
    
    describe "when the user is found" do
      
      describe "when the credentials are invalid" do
        
        it "returns a Castronaut::AuthenticationResult object with the unable to authenticate user message" do
          Castronaut::Adapters::Development::User.stub!(:find_by_login).and_return(stub(:crypted_password => "a", :salt => "b").as_null_object)
          Castronaut::Adapters::Development::User.authenticate('bob', '1234').error_message.should == "Unable to authenticate the username bob"
        end
        
      end
         
    end
    
  end

end
