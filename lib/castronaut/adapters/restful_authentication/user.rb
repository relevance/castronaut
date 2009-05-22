require "digest/sha1"

module Castronaut
  module Adapters
    module RestfulAuthentication
      
      class User < ActiveRecord::Base
      
        def self.digest(password, salt)
          site_key = Castronaut.config.cas_adapter['site_key']
          digest_value = site_key
          
          Castronaut.config.cas_adapter['digest_stretches'].times do
            digest_value = secure_digest(digest_value, salt, password, site_key)
          end
          
          digest_value
        end

        def self.secure_digest(*args)
          Digest::SHA1.hexdigest(args.flatten.join('--'))
        end
        
        def self.find_by_login(login)
          if Castronaut.config.cas_adapter.has_key?('extra_authentication_conditions')
            find(:first, :conditions => ["login = ? AND #{Castronaut.config.cas_adapter['extra_authentication_conditions']}", login])
          else
            find(:first, :conditions => { :login => login })
          end
        end

        def self.authenticate(username, password)
          if user = find_by_login(username)
            if user.crypted_password == Castronaut::Adapters::RestfulAuthentication::User.digest(password, user.salt)
              Castronaut::AuthenticationResult.new(username, nil)
            else
              Castronaut.config.logger.info "#{self} - Unable to authenticate username #{username} due to invalid authentication information"
              Castronaut::AuthenticationResult.new(username, "Unable to authenticate")
            end
          else
            Castronaut.config.logger.info "#{self} - Unable to authenticate username #{username} because it could not be found"
            Castronaut::AuthenticationResult.new(username, "Unable to authenticate")
          end
        end
        
      end
    
    end
  end
end
