module Castronaut
  module Adapters
    module Development
      class Adapter
      
        def self.authenticate(username, password)
          Castronaut::Adapters::Development::User.authenticate(username, password)
        end
      
      end
    end
  end
end
