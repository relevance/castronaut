module Castronaut

  class AuthenticationResult
    
    attr_reader :username, :password, :service, :environment, :error_message
        
    def initialize(username, service, environment, error_message=nil)
      @username = username
      @service = service
      @environment = environment
      @error_message = error_message
      Castronaut.logger.info("#{self.class} - #{@error_message} for #{@username} on #{@service}") if @error_message && @service
    end
    
    def valid?
      error_message.nil?
    end
    
    def invalid?
      !valid?
    end
    
  end

end

