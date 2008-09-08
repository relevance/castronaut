module Castronaut
  module Adapters

    def self.selected_adapter
      Castronaut::Adapters::RestfulAuthentication::Adapter
    end
    
  end
end
