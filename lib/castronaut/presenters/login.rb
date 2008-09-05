module Castronaut
  module Presenters

    class Login
      attr_reader :controller
      attr_accessor :messages

      delegate :params, :request, :to => :controller
      delegate :cookies, :env, :to => :request

      def initialize(controller)
        @controller = controller
        @messages = []
      end

      def service
        params['service']
      end

      def renewal
        params['renew']
      end

      def gateway?
        return true if params['gateway'] == 'true'
        return true if params['gateway'] == '1'
        false
      end

      def ticket_generating_ticket_cookie
        cookies['tgt']
      end

      def redirection_loop?
        params.has_key?('redirection_loop_intercepted')
      end
      
      def client_host
        env['HTTP_X_FORWARDED_FOR'] || env['REMOTE_HOST'] || env['REMOTE_ADDR']
      end
      
      def login_ticket
        Castronaut::Models::LoginTicket.generate_from(client_host)
      end

      def validate
        ticket_granting_ticket_result = Castronaut::Ticket.validate_ticket_granting_ticket(ticket_generating_ticket_cookie)

        if ticket_granting_ticket_result.valid?
          messages << "You are currently logged in as #{ticket_granting_ticket_result.username}.  If this is not you, please log in below."
        end

        if redirection_loop?
          messages << "The client and server are unable to negotiate authentication.  Please try logging in again later."
        end

        if service
          if !renewal && ticket_granting_ticket_result.valid?
            service_ticket = generate_service_ticket(service, ticket_granting_ticket_result.username, ticket_granting_ticket_result.ticket)
            service_with_ticket = service_uri_with_ticket(service, service_ticket)
            return controller.redirect(service, 303)
          end
        elsif gateway?
          messages << "The server cannot fulfill this gateway request because no service parameter was given."
        end
        
        self
      end

      private

      def generate_service_ticket(service, username, ticket_generating_ticket)

      end

      def service_uri_with_ticket(service, service_ticket)

      end
    end

  end
  
end

