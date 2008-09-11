require 'uri'
require 'net/https'

module Castronaut
  module Models

    class ServiceTicket < ActiveRecord::Base
      include Castronaut::Models::Consumeable
      include Castronaut::Models::Dispenser

      MissingMessage = "Ticket or service parameter was missing in the request."

      belongs_to :ticket_granting_ticket
      has_many :proxy_granting_tickets, :dependent => :destroy

      before_validation :dispense_ticket, :if => :new_record?
      validates_presence_of :ticket, :client_hostname, :service, :username, :ticket_granting_ticket

      def self.generate_ticket_for(service, client_host, ticket_granting_ticket)
        create! :service => service,
                :username => ticket_granting_ticket.username,
                :client_hostname => client_host,
                :ticket_granting_ticket => ticket_granting_ticket
      end

      def self.validate_ticket(service, ticket, allow_proxy_tickets = false)

        return Castronaut::TicketResult.new(nil, MissingMessage, "INVALID_REQUEST") unless service && ticket

        service_ticket = find_by_ticket(ticket)

        return Castronaut::TicketResult.new(nil, "Ticket #{ticket} not recognized.", "INVALID_TICKET") unless service_ticket

        return Castronaut::TicketResult.new(service_ticket, "Ticket '#{ticket}' has already been used up.", "INVALID_TICKET") if service_ticket.consumed?

        service_ticket.consume!

        if service_ticket === Castronaut::Models::ProxyTicket && !allow_proxy_tickets
          return Castronaut::TicketResult.new(service_ticket, "Ticket '#{ticket}' is a proxy ticket, but only service tickets are allowed here.", "INVALID_TICKET")
        end

        return Castronaut::TicketResult.new(service_ticket, "Ticket '#{ticket}' has expired.", "INVALID_TICKET") if service_ticket.expired?

        mismatched_service_message = "The ticket '#{ticket}' belonging to user '#{service_ticket.username}' is valid, but the requested service '#{service}' does not match the service '#{service_ticket.service}' associated with this ticket."

        return Castronaut::TicketResult.new(service_ticket, mismatched_service_message, "INVALID_SERVICE") unless service_ticket.matches_service?(service)

        Castronaut::TicketResult.new(service_ticket, nil, "success")
      end

      def matches_service?(other_service)
        service == other_service
      end

      def service_uri
        return nil if service.blank?

        begin
          raw_uri = URI.parse(service)

          if service.include? "?"
            if raw_uri.query.empty?
              query_separator = ""
            else
              query_separator = "&"
            end
          else
            query_separator = "?"
          end

          "#{service}#{query_separator}ticket=#{ticket}"
        rescue URI::InvalidURIError
          nil
        end
      end

      def ticket_prefix
        "ST"
      end

      def expired?
        # Time.now - service_ticket.created_on > CASServer::Conf.service_ticket_expiry
      end
      
      def proxies
      end
      
    end

  end
end
