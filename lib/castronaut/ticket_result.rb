module Castronaut

  class TicketResult
    attr_reader :ticket, :error_message

    def initialize(ticket, error_message=nil)
      @ticket = ticket
      @error_message = error_message
      Ticket.log_debug("#{error_message} for #{ticket}") if @error_message
    end

    def valid?
      error_message.nil?
    end
  end

end

