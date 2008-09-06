module Castronaut
  module Models

    class LoginTicket
      MissingMessage = "Your login request did not include a login ticket. There may be a problem with the authentication system."
      InvalidMessage = "The login ticket you provided is invalid. Please try logging in again."
      AlreadyConsumedMessage = "The login ticket you provided has already been used up. Please try logging in again."
      ExpiredMessage = "Your login ticket has expired. Please try logging in again."
      
      attr_accessor :ticket, :client_hostname
  
      def self.find_by_ticket(ticket)
        
      end
  
      def self.generate_from(client_host)
        login_ticket = LoginTicket.new
        login_ticket.ticket = "LT-#{Castronaut::RandomString.generate}"
        login_ticket.client_hostname = client_host
        login_ticket.save!
        login_ticket
      end
      
      def self.validate_ticket(ticket)
        return Castronaut::TicketResult.new(nil, MissingMessage) if ticket.nil?

        login_ticket = find_by_ticket(ticket)
        
        return Castronaut::TicketResult.new(nil, InvalidMessage) if login_ticket.nil?
        
        return Castronaut::TicketResult.new(login_ticket, AlreadyConsumedMessage) if login_ticket.consumed?
        
        return Castronaut::TicketResult.new(login_ticket, ExpiredMessage) if login_ticket.expired?
        
        login_ticket.consume!

        # $LOG.info("Login ticket '#{ticket}' successfully validated")        
        nil
      end

      def expired?
        #Time.now - lt.created_on < CASServer::Conf.login_ticket_expiry
      end
      
      def save!
        
      end
      
      def consume!
        
      end
  
    end

  end
end
