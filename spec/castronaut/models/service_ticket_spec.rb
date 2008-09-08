require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

describe Castronaut::Models::ServiceTicket do
  
  describe "service uri" do
    
    it "returns nil if no service is present" do
      Castronaut::Models::ServiceTicket.new.service_uri.should be_nil
    end
    
    it "tries to parse service using URI.parse" do
      URI.expects(:parse).with('http://example.com')
      
      service_ticket = Castronaut::Models::ServiceTicket.new(:service => 'http://example.com')
      service_ticket.service_uri
    end
    
    describe "when the service has an existing querystring" do

      it "appends the ticket to the service querystring" do
        service_ticket = Castronaut::Models::ServiceTicket.new(:service => 'http://example.com?foo=bar', :ticket => 'my_ticket')
        service_ticket.service_uri.should == "http://example.com?foo=bar&ticket=my_ticket"
      end

    end
    
    describe "when the service has no querystring" do
      
      it "adds a querystring containing the ticket to the service" do
        service_ticket = Castronaut::Models::ServiceTicket.new(:service => 'http://example.com', :ticket => 'my_ticket')
        service_ticket.service_uri.should == "http://example.com?ticket=my_ticket"
      end
      
    end
    
    describe "when the service has a querystring of '?' only" do
      
      it "removes the question mark" do
        service_ticket = Castronaut::Models::ServiceTicket.new(:service => 'http://example.com?', :ticket => 'my_ticket')
        service_ticket.service_uri.should == "http://example.com?ticket=my_ticket"
      end
            
    end
    
    describe "when you give an invalid URI" do
      
      it "handles the URI::InvalidURIError" do
        URI.expects(:parse).raises(URI::InvalidURIError)

        service_ticket = Castronaut::Models::ServiceTicket.new(:service => 'invalid uri here', :ticket => 'my_ticket')
        service_ticket.service_uri
      end
      
      it "returns nil" do
        service_ticket = Castronaut::Models::ServiceTicket.new(:service => 'invalid uri here', :ticket => 'my_ticket')
        service_ticket.service_uri.should be_nil
      end
      
    end
    
  end
  
end
