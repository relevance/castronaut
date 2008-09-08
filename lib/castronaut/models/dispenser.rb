module Castronaut
  module Models
    
    module Dispenser

      private
       def dispense_ticket
         write_attribute :ticket, "#{ticket_prefix}-#{Castronaut::Utilities::RandomString.generate}"
       end
      
    end
    
  end
end
