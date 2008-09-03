require 'yaml'

module Castronaut

  class Configuration
    DefaultConfigFilePath = './castronaut.yml'
    
    attr_accessor :config_file_path, :config_hash
    
    def initialize(config_file_path = Castronaut::Configuration::DefaultConfigFilePath)
      @config_file_path = config_file_path
      @config_hash = parse_yaml_config(@config_file_path)
      parse_config_into_settings(@config_hash)
    end
    
    private
      def parse_yaml_config(file_path)
        YAML::load_file(file_path)
      end
      
      def parse_config_into_settings(config)
        mod = Module.new { config.each_pair { |k,v| define_method(k) { v } } }
        self.extend mod
      end    
  end
  
end
