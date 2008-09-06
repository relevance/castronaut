module Castronaut
  module Models

    class TicketGrantingTicket
      
      def self.find_by_ticket(ticket)
        
      end
      
      def self.validate_cookie(ticket_cookie)
        $cas_config.logger.debug("#{self} - Validating ticket granting ticket for #{ticket_cookie}")
        
        return Castronaut::TicketResult.new(nil, "No ticket granting ticket given") if ticket_cookie.nil?

        ticket_granting_ticket = find_by_ticket(ticket_cookie)

        if ticket_granting_ticket
          # TODO: Investigate if we need to add configurable session expiry
          return Castronaut::TicketResult.new(ticket_granting_ticket, "Your session has expired. Please log in again.") if ticket_granting_ticket.expired?
          $cas_config.logger.debug("#{self} - Ticket granting ticket [#{ticket_cookie}] for [#{ticket_granting_ticket.username}] successfully validated.")
        else
          $cas_config.logger.debug("#{self} - Ticket granting ticket [#{ticket_cookie}] was not found in the database.")
        end

        Castronaut::TicketResult.new(ticket_granting_ticket)
      end
      
    end
    
  end
end
