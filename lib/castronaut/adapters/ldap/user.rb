module Castronaut
  module Adapters
    module Ldap
      
      class User 
        begin
          require "net/ldap"
        rescue LoadError
          begin
            gem 'ruby-net-ldap', '~> 0.0.4'
          rescue Gem::LoadError
            $stderr.puts "How can you have any pudding if you don\'t install ruby-net-ldap?"
            exit(0)
          end
        end
        
        def self.authenticate(username, password)
          return false if password.blank?
          
          connection = Net::LDAP.new
          connection.host = Castronaut.config.cas_adapter['host']
          connection.port = Castronaut.config.cas_adapter['port']
          
          prefix = Castronaut.config.cas_adapter['prefix']
          base = Castronaut.config.cas_adapter['base']
          
          connection.authenticate("#{prefix}#{username}, #{base}", password)
          if connection.bind
            return Castronaut::AuthenticationResult.new(username, nil)            
          else
            Castronaut.config.logger.info "#{self} - Unable to authenticate username #{username} because #{connection.get_operation_result.message} : code #{connection.get_operation_result.code}"
            return Castronaut::AuthenticationResult.new(username, "Unable to authenticate")
          end
        end

      end
    
    end
  end
end
