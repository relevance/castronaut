require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper'))

describe Castronaut::Adapters::Ldap::User do

  describe "authenticate" do
    
    it "attempts to authenticate the user" do
      connection = stub({}).as_null_object
      Net::LDAP.stub!(:new).and_return(connection)
      connection.should_receive(:authenticate).with('cn=bob, dc=example, dc=com, ', '1234').and_return(nil)
      Castronaut::Adapters::Ldap::User.authenticate('cn=bob, dc=example, dc=com', '1234')
    end
    
    it "returns a failed to authenticate message when authentication fails" do
      connection = stub({}).as_null_object
      Net::LDAP.stub!(:new).and_return(connection)
      connection.stub!(:authenticate).and_return(nil)
      connection.stub!(:bind).and_return(false)
      result = Castronaut::Adapters::Ldap::User.authenticate('cn=bob, dc=example, dc=com', 'bad_password')
      result.error_message.should == "Unable to authenticate the username cn=bob, dc=example, dc=com"
    end
  
  end

end
