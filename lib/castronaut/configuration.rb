require 'yaml'
require 'logger'
require 'fileutils'

module Castronaut

  class Configuration
    DefaultConfigFilePath = './castronaut.yml'
    
    attr_accessor :config_file_path, :config_hash, :logger
    
    def initialize(config_file_path = Castronaut::Configuration::DefaultConfigFilePath)
      @config_file_path = config_file_path
      @config_hash = parse_yaml_config(@config_file_path)
      parse_config_into_settings(@config_hash)
      @logger = setup_logger      
      debug_initialize if logger.debug?
    end
    
    private
      def parse_yaml_config(file_path)
        YAML::load_file(file_path)
      end
      
      def parse_config_into_settings(config)
        mod = Module.new { config.each_pair { |k,v| define_method(k) { v } } }
        self.extend mod
      end    
      
      def create_log_directory(dir)
        FileUtils.mkdir_p(dir) unless File.exist?(dir)
      end
      
      def setup_logger
        create_log_directory(log_directory)
        log = Logger.new("#{log_directory}/castronaut.log", "daily")
        log.level = eval(log_level)
        log
      end
      
      def debug_initialize
        logger.debug "#{self.class} - initializing with parameters"
        config_hash.each_pair do |key, value|
          logger.debug "--> #{key} = #{value.inspect}"
        end
        logger.debug "#{self.class} - initialization complete"
      end
  end
  
end
