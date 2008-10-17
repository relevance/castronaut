require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper'))

describe Castronaut::Adapters::Development::Adapter do

  describe "authenticate" do
    
    it "calls authenticate on the nested User model" do
      Castronaut::Adapters::Development::User.should_receive(:authenticate).with('username', 'password')
      Castronaut::Adapters::Development::Adapter.authenticate('username', 'password')
    end
    
  end

end
