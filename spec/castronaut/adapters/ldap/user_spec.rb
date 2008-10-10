require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper'))

describe Castronaut::Adapters::Ldap::User do

  describe "authenticate" do
    
    it "attempts to authenticate the user" do
      connection = stub_everything
      Net::LDAP.stub!(:new).and_return(connection)
      connection.should_receive(:authenticate).with('cn=bob, dc=example, dc=com, ', '1234').and_return(nil)
      Castronaut::Adapters::Ldap::User.authenticate('cn=bob, dc=example, dc=com', '1234')
    end
    
  end

end
