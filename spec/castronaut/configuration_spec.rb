require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))
require 'yaml'

describe Castronaut::Configuration do
  
  before(:all) do
    @test_config_file = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'castronaut.example.yml'))
  end
  
  describe "initialization" do
    
    it "defaults the config file path to ./castronaut.yml if none is given" do
      Castronaut::Configuration.any_instance.stubs(:parse_config_into_settings)
      Castronaut::Configuration.any_instance.stubs(:parse_yaml_config).returns({})
      Castronaut::Configuration.any_instance.stubs(:setup_logger).returns(stub_everything)
      Castronaut::Configuration.new.config_file_path.should == './castronaut.yml'
    end

    it "uses whatever file path is passed to it as the alternate path" do
      Castronaut::Configuration.any_instance.stubs(:parse_config_into_settings)
      Castronaut::Configuration.any_instance.stubs(:parse_yaml_config).returns({})
      Castronaut::Configuration.any_instance.stubs(:setup_logger).returns(stub_everything)
      Castronaut::Configuration.new("/foo/bar/baz").config_file_path.should == '/foo/bar/baz'
    end
        
    it "parses the file with YAML::load_file into a hash" do
      Castronaut::Configuration.any_instance.stubs(:parse_config_into_settings)
      Castronaut::Configuration.any_instance.stubs(:setup_logger).returns(stub_everything)
      Castronaut::Configuration.new(@test_config_file).config_file_path.should include('castronaut.example.yml')
    end
    
    it "exposes the loaded YAML config at :config_hash" do
      Castronaut::Configuration.any_instance.stubs(:parse_config_into_settings)
      Castronaut::Configuration.any_instance.stubs(:parse_yaml_config).returns(:config_hash)
      Castronaut::Configuration.any_instance.stubs(:setup_logger).returns(stub_everything)
      Castronaut::Configuration.new(@test_config_file).config_hash.should == :config_hash
    end
    
    it "creates the log directory if it doesn't already exist" do
      File.stubs(:exist?).returns(false)
      FileUtils.expects(:mkdir_p)
      Castronaut::Configuration.new(@test_config_file)
    end
    
    it "creates an instance of Logger pointing to the log directory" do
      Logger.expects(:new).with("log/castronaut.log", anything).returns(stub_everything)
      
      Castronaut::Configuration.new(@test_config_file)
    end
    
    it "exposes the logger at :logger" do
      Castronaut::Configuration.new(@test_config_file).logger.should_not be_nil
    end
    
    it "sets the loggers level from the configuration" do
      Castronaut::Configuration.new(@test_config_file).logger.level.should == Logger::DEBUG
    end
    
    it "rotates the logger daily" do
      Logger.expects(:new).with("log/castronaut.log", "daily").returns(stub_everything)
      
      Castronaut::Configuration.new(@test_config_file)
    end
        
  end
  
  describe "configuration settings" do

    before(:all) do
      @yml_config = YAML::load_file(@test_config_file)
    end
    
    it "load of Yaml config for testing should not be nil" do
      @yml_config.should_not be_nil
    end

    %w{organization_name server_port log_directory log_level ssl_enabled cas_database cas_adapter}.each do |config_setting|
      
      describe config_setting do
        
        it "defines a method for the #{config_setting}" do
          Castronaut::Configuration.new(@test_config_file).respond_to?(config_setting).should be_true        
        end

        it "sets the #{config_setting} to the value of the same key in the YAML config" do
          Castronaut::Configuration.new(@test_config_file).send(config_setting).should == @yml_config[config_setting]
        end
        
      end
      
    end

  end

end
