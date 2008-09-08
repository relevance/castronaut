module Castronaut
  module Models
    
    module Consumeable
      
      def consumed?
        !consumed_at.nil?
      end
      
      def consume!
        self.consumed_at = Time.now
        self.save!
      end
      
    end
    
  end
end
