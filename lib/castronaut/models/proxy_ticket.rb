require 'uri'
require 'net/https'

module Castronaut
  module Models

    class ProxyTicket < ServiceTicket

      MissingMessage = "Ticket or service parameter was missing in the request."

      belongs_to :proxy_granting_ticket

      before_validation :dispense_ticket, :if => :new_record?
      validates_presence_of :ticket, :client_hostname, :service, :username, :ticket_granting_ticket

      def self.validate_ticket(service, ticket)
        service_ticket_result = Castronaut::Models::ServiceTicket.validate_ticket(service, ticket, true)

        return service_ticket_result if service_ticket_result.invalid?

        if service_ticket_result.ticket === Castronaut::Models::ProxyTicket
          if service_ticket_result.ticket.proxy_granting_ticket.nil?
            return Castronaut::TicketResult.new(service_ticket_result.ticket, "Proxy ticket '#{service_ticket_result.ticket}' belonging to user '#{service_ticket_result.username}' is not associated with a proxy granting ticket.", "INTERNAL_ERROR")
          elsif service_ticket_result.ticket.proxy_granting_ticket.service_ticket.nil?
            return Castronaut::TicketResult.new(service_ticket_result.ticket, "Proxy granting ticket '#{service_ticket_result.ticket.proxy_granting_ticket}' (associated with proxy ticket '#{service_ticket_result.ticket}' and belonging to user '#{service_ticket_result.username}' is not associated with a service ticket.", "INTERNAL_ERROR")
          end
        end

        Castronaut::TicketResult.new(service_ticket_result.ticket, nil, "success")
      end

      def ticket_prefix
        "PT"
      end
      
      def proxies
        [proxy_granting_ticket.service_ticket.service]
      end

    end

  end
end
