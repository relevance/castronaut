module Castronaut
  module Presenters

    class ServiceValidate
      MissingCredentialsMessage = "Please supply a username and password to login."

      attr_reader :controller, :your_mission
      attr_accessor :messages, :login_ticket

      delegate :params, :request, :to => :controller
      delegate :cookies, :env, :to => :request

      def initialize(controller)
        @controller = controller
        @messages = []
        @your_mission = nil
      end

      def service
        params['service']
      end

      def renewal
        params['renew']
      end

      def ticket
        params['ticket']
      end

      def proxy_granting_ticket_url
        params['pgtUrl']
      end

      def proxy_granting_ticket_iou
        @proxy_granting_ticket_result && @proxy_granting_ticket_result.iou
      end

      def username
        @service_ticket_result.username
      end

      def client_host
        env['HTTP_X_FORWARDED_FOR'] || env['REMOTE_HOST'] || env['REMOTE_ADDR']
      end

      def service_ticket_result
        @service_ticket_result
      end

      def represent!
        @service_ticket_result = Castronaut::Models::ServiceTicket.validate_ticket(service, ticket)

        if @service_ticket_result.valid?
          if proxy_granting_ticket_url
            @proxy_granting_ticket_result = Castronaut::Models::ProxyGrantingTicket.generate_ticket(proxy_granting_ticket_url, client_host, @service_ticket_result.ticket)
          end
        end

        @your_mission = lambda { controller.erb :service_validate, :layout => false, :locals => { :presenter => self } }

        self
      end

    end

  end
end
