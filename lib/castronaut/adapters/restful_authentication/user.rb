require "digest/sha1"

module Castronaut
  module Adapters
    module RestfulAuthentication
      
      class User < ActiveRecord::Base
      
        before_save :generate_encryption_salt

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
        
        def self.authenticate(username, password)
          if user = find_by_login(username)
            if user.crypted_password == Castronaut::Adapters::RestfulAuthentication::User.digest(password, user.salt)
              Castronaut::AuthenticationResult.new(username, nil)
            else
              Castronaut::AuthenticationResult.new(username, "Unable to authenticate the username #{username}")
            end
          else
            Castronaut::AuthenticationResult.new(username, "Unable to authenticate the username #{username}")
          end
        end
        
      end
    
    end
  end
end
