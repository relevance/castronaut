module Castronaut
  module Presenters

    class Logout
      attr_reader :controller, :your_mission
      attr_accessor :messages

      delegate :params, :request, :to => :controller
      delegate :cookies, :env, :to => :request

      def initialize(controller)
        @controller = controller
        @messages = []
        @your_mission = nil
      end

      def url
        params['url']
      end

      def ticket_granting_ticket_cookie
        cookies['tgt']
      end

      def client_host
        env['HTTP_X_FORWARDED_FOR'] || env['REMOTE_HOST'] || env['REMOTE_ADDR']
      end
      
      def login_ticket
        Castronaut::Models::LoginTicket.generate_from(client_host).ticket
      end

      def represent!
        ticket_granting_ticket = Castronaut::Models::TicketGrantingTicket.find_by_ticket(ticket_granting_ticket_cookie) 
        
        cookies.delete 'tgt'
        controller.response.delete_cookie('tgt')

        if ticket_granting_ticket
          Castronaut::Models::ProxyGrantingTicket.clean_up_proxy_granting_tickets_for(ticket_granting_ticket.username)
          ticket_granting_ticket.destroy
        end
        
        messages << "You have successfully logged out."
        
        @your_mission = lambda { controller.erb :logout, :locals => { :presenter => self } }
                
        self
      end
    
    end

  end
  
end

