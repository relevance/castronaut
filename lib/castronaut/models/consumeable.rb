module Castronaut
  module Models
    
    module Consumeable
      
      def consumed?
        !consumed.nil?
      end
      
      def consume!
        self.consumed = Time.now
        self.save!
      end
      
    end
    
  end
end
