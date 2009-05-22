require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Castronaut do
  
  after(:all) do
    Castronaut.config = Castronaut::Configuration.load(File.join(File.dirname(__FILE__), '..', 'config', 'castronaut.example.yml'))
  end
  
  it "exposes the config at Castronaut.config" do
    Castronaut.config.should == Castronaut.instance_variable_get("@cas_config")
  end
  
  it "allows you to reset the config" do
    new_config = stub({}).as_null_object
    original_config = Castronaut.config
    
    Castronaut.config.should_not == new_config
    Castronaut.config = new_config
    Castronaut.config.should == new_config
  end
  
  it "exposes the configuration logger as Castronaut.logger" do
    Castronaut.logger.should == Castronaut.config.logger
  end

end
