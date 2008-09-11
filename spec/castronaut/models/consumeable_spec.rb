require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

describe Castronaut::Models::Consumeable do
  
  class FakeModel
    include Castronaut::Models::Consumeable

    attr_accessor :consumed_at, :id
    
    def save!
      
    end
  end
  
  describe "consume!" do
  
    it "sets consumed to the current time" do
      fake_model = stub_model(FakeModel).as_new_record
      fake_model.should_receive(:consumed_at=)
      fake_model.consume!
    end
    
    it "calls save!" do
      fake_model = stub_model(FakeModel).as_new_record
      fake_model.should_receive(:save!)
      fake_model.consume!
    end
  
  end
  
  it "is consumed when consumed_at has a value" do
    fake_model = FakeModel.new
    fake_model.should_not be_consumed
    
    fake_model.consumed_at = Time.now
    fake_model.should be_consumed
  end
  
end
