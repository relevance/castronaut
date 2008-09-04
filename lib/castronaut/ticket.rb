module Castronaut
  class TicketGrantingTicket

    #TODO: implement when needed
    def expired?

    end

  end

  class TicketResult
    attr_reader :ticket, :error_message

    def initialize(ticket, error_message=nil)
      @ticket = ticket
      @error_message = error_message
      Ticket.log_debug("#{error_message} for #{ticket}") if @error_message
    end

    def valid?
      error_message.nil?
    end
  end

  class Ticket

    def self.validate_ticket_granting_ticket(ticket)
      log_debug("Validating ticket granting ticket for #{ticket}")

      return TicketResult.new(nil, "No ticket granting ticket given") if ticket.nil?

      ticket_granting_ticket = TicketGrantingTicket.find_by_ticket(ticket)

      if ticket_granting_ticket
        # TODO: Investigate if we need to add configurable session expiry
        return TicketResult.new(ticket_granting_ticket, "Your session has expired. Please log in again.") if ticket_granting_ticket.expired?
        log_info("Ticket granting ticket [#{ticket}] for [#{ticket_granting_ticket.username}] successfully validated.")
      else
        log_warn("Ticket granting ticket [#{ticket}] was not found in the database.")
      end

      TicketResult.new(ticket_granting_ticket)
    end


    def self.log_debug(message)
      $cas_config.logger.debug("Castronaut::TicketValidator - #{message}")
    end

    def self.log_info(message)
      $cas_config.logger.info("Castronaut::TicketValidator - #{message}")
    end

    def self.log_warn(message)
      $cas_config.logger.warn("Castronaut::TicketValidator - #{message}")
    end
  end

end

