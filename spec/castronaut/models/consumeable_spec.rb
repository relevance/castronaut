require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

describe Castronaut::Models::Consumeable do
  
  class FakeModel
    include Castronaut::Models::Consumeable

    attr_accessor :consumed_at
    
    def save!
      
    end
  end
  
  describe "consume!" do
  
    it "sets consumed to the current time" do
      FakeModel.any_instance.expects(:consumed_at=)
      FakeModel.new.consume!
    end
    
    it "calls save!" do
      FakeModel.any_instance.expects(:save!)
      FakeModel.new.consume!      
    end
  
  end
  
  it "is consumed when consumed_at has a value" do
    fm = FakeModel.new
    fm.should_not be_consumed
    
    fm.consumed_at = Time.now
    fm.should be_consumed
  end
  
end
