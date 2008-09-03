require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe Castronaut do
  
  describe 'Logger' do
    
    it 'has a logger for the CAS functionality'
    
    it 'has a logger for the Sintra server'
    
  end
  
  describe "Utilities" do
    
    describe "Random string generation" do
      
      it "generates random string with a given length using ISAAC"
      
    end
    
    describe "Clean service url [phase2]" do
      
      it "strips duplicate recognized keys keeping only the first from the querystring"
      
      it "removes the slash after a domain (ie bob.com/ => bob.com)"
      
    end

  end
  
  describe 'Server' do
    
    describe "Command line runner" do
      
      it "allows you to specify the path to the config file as a command-line option"
    
    end
    
    describe "Initializer" do
      
      it "asks for the the configuration"
    
      it "sets the logger to the configuration.logger"
      
      it "delegates the port to the configuration"
      
      it "sets the ssl mode from the configuration"
      
      it "connects to the CAS database from the configuration"
      
      it "connects to the CAS adapter database from the configuration"
    
      it "ensures the CAS database is migrated to the current version"
            
    end
    
    it "starts up the sintra app"
  
  end
  
  describe "Ticket Generators" do
  
    describe 'Login Ticket' do

      it "generates a new Ticket"

      it "has a random ticket attribute generated using ISAAC"

      it "captures the client hostname on the ticket"

      it "can be marked as consumed/used"
      
      describe "Validations" do
        
      end

    end
    
    describe 'Ticket Granting Ticket' do
      
      it "generates a new Ticket"     
      
      it "has a random ticket attribute generated using ISAAC"   
      
      it "captures the client hostname on the ticket"
            
      it "has a username"
      
      it "has extra attributes"
      
      describe "Validations" do
        
      end
      
    end
    
    describe 'Service Ticket' do
      
      it "generates a new Ticket"

      it "has a random ticket attribute generated using ISAAC"      
      
      it "has a service"
      
      it "requires a ticket granting ticket"
      
      it "has a username"
      
      it "captures the client hostname on the ticket"
            
      it "can be marked as consumed/used"      
      
      describe "Validations" do
        
      end
      
    end
   
  end
  
  describe 'Restful Authentication Adapter' do
    
    describe "Password encryption" do
    
      it "includes the restful auth password encryption routines if possible directly from the gem/plugin"
      
    end
    
    describe "Validation" do
      
      it "reads the standard credentials"
      
      describe "finding the user" do

        it "looks up a CasUser in the CAS database from the credentials username"

        describe "returning 0 results" do
          
          it "returns false"
          
        end
        
        describe "returning 1 result" do
          
          it "ensures the given password hash matches the encrypted version"
          
        end
        
        describe "returning 2 or more results" do
          
          it "writes a warning to the logger"
          
          it "selects the first user"
          
          it "ensures the first users given password hash matches the encrypted version"
          
        end        
      end
    end
    
  end
  
  describe "CasUser" do
    
    it "should be hooked up to the CAS adapter database"
    
    it "should include the Restful Auth bits"
    
  end
    
  describe "Our rake tasks" do
    
    describe "SSL Certificate Generation" do
      
      it "generates a self-signed ssl cert for use in dev mode [nth]"
      
    end
    
  end
  
  describe "Controllers" do
    
    it "matches the current URL scheme from rubycas-server"
    
  end

end
