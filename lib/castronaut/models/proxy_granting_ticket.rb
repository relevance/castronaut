require 'uri'
require 'net/https'

module Castronaut
  module Models

    class ProxyGrantingTicket < ActiveRecord::Base
      belongs_to :service_ticket

      before_validation :dispense_ticket, :if => :new_record?
      before_validation :dispense_iou, :if => :new_record?
      
      validates_presence_of :ticket, :client_hostname, :iou

      def self.generate_ticket(proxy_granting_ticket_url, client_host, service_ticket)
        
        begin
          uri = URI.parse(proxy_granting_ticket_url)
        rescue URI::InvalidURIError
          return Castronaut::TicketResult.new(nil, "Unable to parse pgt_url '#{proxy_granting_ticket_url}'", "warn")
        end
        
        https = Net::HTTP.new(uri.host,uri.port)
        https.use_ssl = true

        https.start do |http_connection|
          path = uri.path.empty? ? '/' : uri.path

          proxy_granting_ticket = ProxyGrantingTicket.new(:service_ticket => service_ticket, :client_hostname => client_host)
          proxy_granting_ticket.dispense_ticket
          proxy_granting_ticket.dispense_iou
          
          path += (uri.query.nil? || uri.query.empty? ? '?' : '&') + "pgtId=#{proxy_granting_ticket.ticket}&pgtIou=#{proxy_granting_ticket.iou}"

          http_response = http_connection.request_get(path)

          if http_response.code.to_i == 200
            proxy_granting_ticket.save!
            
            return Castronaut::TicketResult.new(proxy_granting_ticket, "PGT generated for pgt_url '#{proxy_granting_ticket_url}': #{proxy_granting_ticket.inspect}", "success")
          else
            return Castronaut::TicketResult.new(nil, "PGT callback server responded with a bad result code '#{http_response.code}'. PGT will not be stored.", "warn")
          end
        end
      end
      
      def self.clean_up_proxy_granting_tickets_for(username)
        proxy_granting_tickets = all(:include => :service_ticket, :conditions => ["service_tickets.username = ?", username])
        proxy_granting_tickets.each { |pgt| pgt.destroy }
        nil
      end

      def dispense_ticket
        write_attribute(:ticket, "PGT-#{Castronaut::Utilities::RandomString.generate(60)}") if ticket.nil?
      end
      
      def dispense_iou
        write_attribute(:iou, "PGTIOU-#{Castronaut::Utilities::RandomString.generate(57)}") if iou.nil?
      end
      
      def username
      end
      
      def proxies
      end
      
    end
    
  end
end
