module Castronaut
  module Models

    class LoginTicket
  
      attr_accessor :ticket, :client_hostname
  
      def self.generate_from(client_host)
        login_ticket = LoginTicket.new
        login_ticket.ticket = "LT-#{Castronaut::RandomString.generate}"
        login_ticket.client_hostname = client_host
        login_ticket.save!
        login_ticket
      end
      
      def save!
        
      end
  
    end

  end
end
