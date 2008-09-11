module Castronaut
  module Presenters

    class ProcessLogin
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

      def username
        params['username'].to_s.strip
      end

      def password
        params['password']
      end

      def represent!
        @login_ticket = params['lt']

        login_ticket_validation_result = Castronaut::Models::LoginTicket.validate_ticket(@login_ticket)

        if login_ticket_validation_result.invalid?
          messages << login_ticket_validation_result.message
          @login_ticket = Castronaut::Models::LoginTicket.generate_from(client_host).ticket
          @your_mission = lambda { controller.erb :login, :locals => { :presenter => self } } # TODO: STATUS 401
          return self
        end

        if username.blank? || password.blank?
          messages << MissingCredentialsMessage
          @login_ticket = Castronaut::Models::LoginTicket.generate_from(client_host).ticket
          @your_mission = lambda { controller.erb :login, :locals => { :presenter => self } } # TODO: STATUS 401
          return self
        end

        @login_ticket = Castronaut::Models::LoginTicket.generate_from(client_host).ticket

        Castronaut.logger.info("#{self.class} - Logging in with username: #{username}, login ticket: #{login_ticket}, service: #{service}")

        authentication_result = Castronaut::Adapters.selected_adapter.authenticate(username, password)

        if authentication_result.valid?
          ticket_granting_ticket = Castronaut::Models::TicketGrantingTicket.generate_for(username, client_host)
          cookies[:tgt] = ticket_granting_ticket.to_cookie

          if service.blank?
            messages << "You have successfully logged in."
          else
            service_ticket = Castronaut::Models::ServiceTicket.generate_ticket_for(service, client_host, ticket_granting_ticket)

            if service_ticket && service_ticket.service_uri
              @your_mission = lambda { controller.redirect(service_ticket.service_uri, 303) }
              return self
            else
              messages << "The target service your browser supplied appears to be invalid. Please contact your system administrator for help."
            end
          end

        else
          messages << authentication_result.error_message
        end

        if messages.any?
          @your_mission = lambda { controller.erb :login, :locals => { :presenter => self } }
        end

        self
      end

    end

  end
end
