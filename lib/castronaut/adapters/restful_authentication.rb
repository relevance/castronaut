module Castronaut
  module Adapters

    class RestfulAuthentication
      
      def self.authenticate(username, password, service, environment)
        Castronaut::AuthenticationResult.new(username, service, environment, nil)
      end
      
    end
    
  end
end
