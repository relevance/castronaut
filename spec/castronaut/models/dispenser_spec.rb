require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

describe Castronaut::Models::Dispenser do
  module Foo
    module Bar
      
      class FakeModel
        include Castronaut::Models::Dispenser
    
        attr_accessor :ticket
    
        def ticket_prefix
          "WOO!"
        end
    
        def write_attribute(attr, value)
          instance_variable_set "@#{attr}", value
        end
      end
      
    end
  end
  
  it "returns WOO!-RandomString for Foo::Bar::FakeModel" do
    Castronaut::Utilities::RandomString.stubs(:generate).returns("RANDOM")
    
    Foo::Bar::FakeModel.new.send(:dispense_ticket).should == "WOO!-RANDOM"
  end
  
end
