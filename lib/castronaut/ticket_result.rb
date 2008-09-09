module Castronaut

  class TicketResult
    InvalidMessageCategories = %w{warn error fatal invalid} 

    attr_reader :ticket, :message, :message_category
        
    def initialize(ticket, message=nil, message_category=nil)
      @ticket = ticket
      @message = message
      @message_category = message_category
      Castronaut.logger.info("#{self.class} - #{@message_category} #{@message} for #{@ticket}") if @message && @ticket
    end
    
    def username
      ticket.username if ticket && ticket.respond_to?(:username)
    end

    def valid?
      !invalid?
    end
    
    def invalid?
      InvalidMessageCategories.any?{ |cat| message_category.to_s.downcase.include?(cat) }
    end
    
  end

end

