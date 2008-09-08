require 'uri'
require 'net/https'

module Castronaut
  module Models

    class ServiceTicket < ActiveRecord::Base
      include Castronaut::Models::Consumeable
      include Castronaut::Models::Dispenser
      
      belongs_to :ticket_granting_ticket
      
      before_validation :dispense_ticket, :if => :new_record?
      validates_presence_of :ticket, :client_hostname, :service, :username, :ticket_granting_ticket

      def self.generate_ticket_for(service, client_host, ticket_result)
        create! :service => service,
                :username => ticket_result.username,
                :client_hostname => client_host,
                :ticket_granting_ticket => ticket_result.ticket
      end
      
      # Note: URI.parse is prone to throwing up exceptions if it doesn't like what it sees.
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
          # TODO: Log message
        end
      end
      
      def ticket_prefix
        "ST"
      end
      
    end

  end
end
