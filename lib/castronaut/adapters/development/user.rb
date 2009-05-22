module Castronaut
  module Adapters
    module Development
      
      class User < ActiveRecord::Base
      
        def self.authenticate(username, password)
          if user = find_by_login(username)
            if user.password == password
              Castronaut::AuthenticationResult.new(username, nil)
            else
              Castronaut.config.logger.info "#{self} - Unable to authenticate username #{username} due to invalid authentication information"
              Castronaut::AuthenticationResult.new(username, "Unable to authenticate")
            end
          else
            Castronaut.config.logger.info "#{self} - Unable to authenticate username #{username} because it could not be found"
            Castronaut::AuthenticationResult.new(username, "Unable to authenticate")
          end
        end
        
      end
    
    end
  end
end
