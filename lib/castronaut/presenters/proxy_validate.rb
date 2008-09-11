module Castronaut
  module Presenters

    class ProxyValidate
      MissingCredentialsMessage = "Please supply a username and password to login."

      attr_reader :controller, :your_mission, :proxy_ticket_result, :proxies
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
        @proxy_ticket_result.username
      end

      def client_host
        env['HTTP_X_FORWARDED_FOR'] || env['REMOTE_HOST'] || env['REMOTE_ADDR']
      end

      def represent!
        @proxy_ticket_result = Castronaut::Models::ProxyTicket.validate_ticket(service, ticket)

        if @proxy_ticket_result.valid?
          @proxies = @proxy_ticket_result.proxies

          if proxy_granting_ticket_url
            @proxy_granting_ticket_result = Castronaut::Models::ProxyGrantingTicket.generate_ticket(proxy_granting_ticket_url, client_host, @proxy_ticket_result.ticket)
          end
        end

        @your_mission = lambda { controller.erb :proxy_validate, :layout => false, :locals => { :presenter => self } }

        self
      end

    end

  end
end

