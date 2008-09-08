module Castronaut

  class AuthenticationResult
    
    attr_reader :username, :error_message
        
    def initialize(username, error_message=nil)
      @username = username
      @error_message = error_message
      Castronaut.logger.info("#{self.class} - #{@error_message} for #{@username}") if @error_message && @username
    end
    
    def valid?
      error_message.nil?
    end
    
    def invalid?
      !valid?
    end
    
  end

end

