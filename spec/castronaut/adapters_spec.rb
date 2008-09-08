require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe Castronaut::Adapters do
  
  describe "selected adapter" do
    
    it "delegates to the default of RestfulAuthentication" do
      Castronaut::Adapters.selected_adapter.should == Castronaut::Adapters::RestfulAuthentication
    end
    
  end

end
