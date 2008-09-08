module Castronaut
  module Adapters
    module RestfulAuthentication
      
      class Adapter
      
        def self.authenticate(username, password)
          Castronaut::Adapters::RestfulAuthentication::User.authenticate(username, password)
        end
      
      end
    
    end
  end
end
