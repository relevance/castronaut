module Castronaut
  module Models
    
    module Dispenser

      private
       def dispense_ticket
         short_name = self.class.to_s.split("::").last
         initials = short_name.underscore.split("_").map { |name| name.first.upcase }
         write_attribute :ticket, "#{initials}-#{Castronaut::Utilities::RandomString.generate}"
       end
      
    end
    
  end
end
