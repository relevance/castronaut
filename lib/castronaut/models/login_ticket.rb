module Castronaut
  module Models

    class LoginTicket < ActiveRecord::Base
      include Castronaut::Models::Consumeable
      include Castronaut::Models::Dispenser

      MissingMessage = "Your login request did not include a login ticket. There may be a problem with the authentication system."
      InvalidMessage = "The login ticket you provided is invalid. Please try logging in again."
      AlreadyConsumedMessage = "The login ticket you provided has already been used up. Please try logging in again."
      ExpiredMessage = "Your login ticket has expired. Please try logging in again."

      before_validation :dispense_ticket, :if => :new_record?
      validates_presence_of :ticket, :client_hostname 

      def self.generate_from(client_host)
        create! :client_hostname => client_host
      end

      def self.validate_ticket(ticket)
        return Castronaut::TicketResult.new(nil, MissingMessage) if ticket.nil?

        login_ticket = find_by_ticket(ticket)

        return Castronaut::TicketResult.new(nil, InvalidMessage) if login_ticket.nil?

        return Castronaut::TicketResult.new(login_ticket, AlreadyConsumedMessage) if login_ticket.consumed?

        return Castronaut::TicketResult.new(login_ticket, ExpiredMessage) if login_ticket.expired?

        login_ticket.consume!

        Castronaut::TicketResult.new(login_ticket, nil, "success")
      end

      def expired?
        #Time.now - lt.created_on < CASServer::Conf.login_ticket_expiry
      end
 
      def ticket_prefix
        "LT"
      end
      
      def username
      end
      
      def proxies
      end
      
    end

  end
end
