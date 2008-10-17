module Castronaut
  module Adapters
    
    def self.selected_adapter
      case Castronaut.config.cas_adapter['adapter']
        when "development" : Castronaut::Adapters::Development::Adapter
        when "ldap" : Castronaut::Adapters::Ldap::Adapter
        when "database" : Castronaut::Adapters::RestfulAuthentication::Adapter
      end
    end
    
  end
end
