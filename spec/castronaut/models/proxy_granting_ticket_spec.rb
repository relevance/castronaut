require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))
include Castronaut::Models

describe Castronaut::Models::ProxyGrantingTicket do

  it "has no username" do
    ProxyGrantingTicket.new.username.should be_nil
  end

  it "has no proxies" do
    ProxyGrantingTicket.new.proxies.should be_nil
  end

  describe "dispensing a ticket" do
    
    it "starts with PGT" do
      ProxyGrantingTicket.new.send(:dispense_ticket).starts_with?("PGT").should be_true
    end
    
    it "is 64 characters long" do
      ProxyGrantingTicket.new.send(:dispense_ticket).size.should == 64
    end
    
    it "uses the random string generation for the remaining 60 characters" do
      Castronaut::Utilities::RandomString.should_receive(:generate).with(60)
      ProxyGrantingTicket.new.send(:dispense_ticket)
    end
    
  end
  
  describe "dispensing an iou" do
    
    it "starts with PGTIOU" do
      ProxyGrantingTicket.new.send(:dispense_iou).starts_with?("PGTIOU").should be_true
    end
    
    it "is 64 characters long" do
      ProxyGrantingTicket.new.send(:dispense_iou).size.should == 64
    end
    
    it "uses the random string generation for the remaining 57 characters" do
      Castronaut::Utilities::RandomString.should_receive(:generate).with(57)
      ProxyGrantingTicket.new.send(:dispense_iou)
    end
    
  end
  
  describe "generating a proxy granting ticket" do
    
    it "attempts to parse the given url with URI.parse" do
      URI.should_receive(:parse).with('http://pgturl').and_raise(URI::InvalidURIError)
      ProxyGrantingTicket.generate_ticket('http://pgturl', '10.1.1.1', 'service ticket')
    end
    
    describe "when proxy granting ticket url is invalid it returns a ticket result" do
      
      it "with a message indicating it was unable to parse the given url" do
        URI.should_receive(:parse).with('http://pgturl').and_raise(URI::InvalidURIError)
        ProxyGrantingTicket.generate_ticket('http://pgturl', '10.1.1.1', 'service ticket').message.should == "Unable to parse pgt_url 'http://pgturl'"
      end
      
      it "with a message category of warn" do
        URI.should_receive(:parse).with('http://pgturl').and_raise(URI::InvalidURIError)
        ProxyGrantingTicket.generate_ticket('http://pgturl', '10.1.1.1', 'service ticket').message_category.should == 'warn'
      end
      
    end
    
    describe "when proxy granting ticket url is valid" do
 
      it "creates a new net/http connection to uri host and port" do
        https = stub_everything
        Net::HTTP.stub!(:new).and_return(https)  
        
        uri = stub('uri', :host => 'example.com', :port => 443, :path => '')
        URI.stub!(:parse).and_return(uri)
        
        Net::HTTP.should_receive(:new).with('example.com', 443).and_return(https)
        ProxyGrantingTicket.generate_ticket('http://example.com', '10.1.1.1', 'service ticket')
      end
      
      it "sets the new net/http connection to use ssl" do
        https = stub_everything
        Net::HTTP.stub!(:new).and_return(https)  
        
        uri = stub_everything(:host => 'example.com', :port => 443, :path => '')
        URI.stub!(:parse).and_return(uri)
        
        https.should_receive(:use_ssl=).with(true)

        Net::HTTP.stub!(:new).with('example.com', 443).and_return(https)

        ProxyGrantingTicket.generate_ticket('http://example.com', '10.1.1.1', 'service ticket')
      end
      
      it "starts the connection" do
        https = stub_everything
        Net::HTTP.stub!(:new).and_return(https)  
        
        uri = stub_everything(:host => 'example.com', :port => 443, :path => '')
        URI.stub!(:parse).and_return(uri)
        
        https.should_receive(:start)
        
        ProxyGrantingTicket.generate_ticket('http://example.com', '10.1.1.1', 'service ticket')
      end
      
      describe "inside the http connection block" do
        
        it "intializes a new proxy granting ticket" do
          https = stub_everything
          Net::HTTP.stub!(:new).and_return(https)  

          uri = stub_everything(:host => 'example.com', :port => 443, :path => '')
          URI.stub!(:parse).and_return(uri)
          
          https.stub!(:start).and_yield(stub_everything(:request_get => stub_everything))
          
          ProxyGrantingTicket.should_receive(:new).with(:service_ticket => 'service ticket', :client_hostname => '10.1.1.1').and_return(stub_everything)
          ProxyGrantingTicket.generate_ticket('http://example.com', '10.1.1.1', 'service ticket')
        end
        
        it "dispenses a new ticket for the proxy granting ticket" do
          https = stub_everything
          Net::HTTP.stub!(:new).and_return(https)  

          uri = stub_everything(:host => 'example.com', :port => 443, :path => '')
          URI.stub!(:parse).and_return(uri)

          https.stub!(:start).and_yield(stub_everything(:request_get => stub_everything))

          proxy_granting_ticket = stub_everything
          proxy_granting_ticket.should_receive(:dispense_ticket)
          ProxyGrantingTicket.stub!(:new).and_return(proxy_granting_ticket)
          
          ProxyGrantingTicket.generate_ticket('http://example.com', '10.1.1.1', 'service ticket')
        end

        it "dispenses a new iou for the proxy granting ticket" do
          https = stub_everything
          Net::HTTP.stub!(:new).and_return(https)  

          uri = stub_everything(:host => 'example.com', :port => 443, :path => '')
          URI.stub!(:parse).and_return(uri)

          https.stub!(:start).and_yield(stub_everything(:request_get => stub_everything))

          proxy_granting_ticket = stub_everything
          proxy_granting_ticket.should_receive(:dispense_iou)
          ProxyGrantingTicket.stub!(:new).and_return(proxy_granting_ticket)
          
          ProxyGrantingTicket.generate_ticket('http://example.com', '10.1.1.1', 'service ticket')
        end
        
        it "requests the proxy granting ticket path via GET" do
          https = stub_everything
          Net::HTTP.stub!(:new).and_return(https)  

          uri = stub_everything(:host => 'example.com', :port => 443, :path => '')
          URI.stub!(:parse).and_return(uri)
          http_connection = mock('httpconnection')
          http_connection.should_receive(:request_get).with('/?pgtId=PGT-RANDOM&pgtIou=PGTIOU-RANDOM').and_return(stub_everything)
          
          https.stub!(:start).and_yield(http_connection)
          
          ProxyGrantingTicket.stub!(:new).and_return(stub('proxy granting ticket', :iou => 'PGTIOU-RANDOM', :ticket => 'PGT-RANDOM', :dispense_ticket => nil, :dispense_iou => nil))
          
          ProxyGrantingTicket.generate_ticket('http://example.com', '10.1.1.1', 'service ticket')
        end
        
        describe "when the request to the proxy granting ticket path is successful" do
          
          it "saves the proxy granting ticket" do
            https = stub_everything
            Net::HTTP.stub!(:new).and_return(https)  

            uri = stub('uri', :host => 'example.com', :port => 443, :path => '', :query => '')
            URI.stub!(:parse).and_return(uri)
            http_connection = mock('httpconnection')
            http_connection.stub!(:request_get).and_return(stub('response', :code => '200'))
            https.stub!(:start).and_yield(http_connection)

            proxy_granting_ticket = mock_model(ProxyGrantingTicket, :ticket => 'PGT-RANDOM', :iou => 'PGTIOU-RANDOM', :dispense_ticket => nil, :dispense_iou => nil)
            proxy_granting_ticket.should_receive(:save!)
            
            ProxyGrantingTicket.stub!(:new).and_return(proxy_granting_ticket)

            ProxyGrantingTicket.generate_ticket('http://example.com', '10.1.1.1', 'service ticket')
          end
          
          describe "returns a ticket result" do
            
            it "with the proxy granting ticket" do
              https = stub_everything
              Net::HTTP.stub!(:new).and_return(https)  

              uri = stub('uri', :host => 'example.com', :port => 443, :path => '', :query => '')
              URI.stub!(:parse).and_return(uri)
              http_connection = mock('httpconnection')
              http_connection.stub!(:request_get).and_return(stub('request', :code => '200'))
              https.stub!(:start).and_yield(http_connection)

              proxy_granting_ticket = stub('ProxyGrantingTicket', :ticket => 'PGT-RANDOM', :iou => 'PGTIOU-RANDOM', :dispense_ticket => nil, :dispense_iou => nil, :save! => nil)
              ProxyGrantingTicket.stub!(:new).and_return(proxy_granting_ticket)              
              
              ProxyGrantingTicket.generate_ticket('http://example.com', '10.1.1.1', 'service ticket').ticket.should == proxy_granting_ticket
            end
            
            it "with a proxy granting ticket generated message" do
              https = stub_everything
              Net::HTTP.stub!(:new).and_return(https)  

              uri = stub_everything(:host => 'example.com', :port => 443, :path => '')
              URI.stub!(:parse).and_return(uri)
              http_connection = mock('httpconnection')
              http_connection.stub!(:request_get).and_return(stub('request', :code => '200'))
              https.stub!(:start).and_yield(http_connection)

              proxy_granting_ticket = stub('proxy granting ticket', :iou => 'PGTIOU-RANDOM', :ticket => 'PGT-RANDOM', :dispense_ticket => nil, :dispense_iou => nil, :save! => true, :inspect => 'PGT-INSPECT')
              ProxyGrantingTicket.stub!(:new).and_return(proxy_granting_ticket)              
              
              ProxyGrantingTicket.generate_ticket('http://example.com', '10.1.1.1', 'service ticket').message.should == "PGT generated for pgt_url 'http://example.com': PGT-INSPECT"
            end
            
            it "with a message category of success" do
              https = stub_everything
              Net::HTTP.stub!(:new).and_return(https)  

              uri = stub_everything(:host => 'example.com', :port => 443, :path => '')
              URI.stub!(:parse).and_return(uri)
              http_connection = mock('httpconnection')
              http_connection.stub!(:request_get).and_return(stub('request', :code => '200'))
              https.stub!(:start).and_yield(http_connection)

              proxy_granting_ticket = stub_everything(:iou => 'PGTIOU-RANDOM', :ticket => 'PGT-RANDOM', :save! => true)
              ProxyGrantingTicket.stub!(:new).and_return(proxy_granting_ticket)              
              
              ProxyGrantingTicket.generate_ticket('http://example.com', '10.1.1.1', 'service ticket').message_category.should == 'success'
            end
                      
          end

        end
        
        describe "when the request to the proxy granting ticket path has failed" do
          
           describe "returns a ticket result" do

              it "with a proxy granting ticket generated message" do
                https = stub_everything
                Net::HTTP.stub!(:new).and_return(https)  

                uri = stub_everything(:host => 'example.com', :port => 443, :path => '')
                URI.stub!(:parse).and_return(uri)
                http_connection = mock('httpconnection')
                http_connection.stub!(:request_get).and_return(stub('request', :code => '404'))
                https.stub!(:start).and_yield(http_connection)

                proxy_granting_ticket = stub_everything(:iou => 'PGTIOU-RANDOM', :ticket => 'PGT-RANDOM', :save! => true, :inspect => 'PGT-INSPECT')
                ProxyGrantingTicket.stub!(:new).and_return(proxy_granting_ticket)              

                ProxyGrantingTicket.generate_ticket('http://example.com', '10.1.1.1', 'service ticket').message.should == "PGT callback server responded with a bad result code '404'. PGT will not be stored."
              end

              it "with a message category of success" do
                https = stub_everything
                Net::HTTP.stub!(:new).and_return(https)  

                uri = stub_everything(:host => 'example.com', :port => 443, :path => '')
                URI.stub!(:parse).and_return(uri)
                http_connection = mock('httpconnection')
                http_connection.stub!(:request_get).and_return(stub_everything(:code => '404'))
                https.stub!(:start).and_yield(http_connection)

                proxy_granting_ticket = stub_everything(:iou => 'PGTIOU-RANDOM', :ticket => 'PGT-RANDOM', :save! => true)
                ProxyGrantingTicket.stub!(:new).and_return(proxy_granting_ticket)              

                ProxyGrantingTicket.generate_ticket('http://example.com', '10.1.1.1', 'service ticket').message_category.should == 'warn'
              end
            
            end
          
        end
        
      end
      #      path += (uri.query.nil? || uri.query.empty? ? '?' : '&') + "pgtId=#{proxy_granting_ticket.ticket}&pgtIou=#{proxy_granting_ticket.iou}"
      # 
      #      http_response = http_connection.request_get(path)
      # 
      #      if http_response.code.to_i == 200
      #        proxy_granting_ticket.save!
      #        
      #        return Castronaut::TicketResult.new(proxy_granting_ticket, "PGT generated for pgt_url '#{proxy_granting_ticket_url}': #{proxy_granting_ticket.inspect}", "success")
      #      else
      #        return Castronaut::TicketResult.new(nil, "PGT callback server responded with a bad result code '#{http_response.code}'. PGT will not be stored.", "warn")
      #      end
      #    end
      
      
    end
    
  end

end
