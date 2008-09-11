require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

include Castronaut::Models

describe Castronaut::Models::ServiceTicket do

  it "has no proxies" do
    ServiceTicket.new.proxies.should be_nil
  end
  
  it "has a ticket prefix of ST" do
    ServiceTicket.new.ticket_prefix.should == 'ST'
  end

  describe "service uri" do

    it "returns nil if no service is present" do
      ServiceTicket.new.service_uri.should be_nil
    end

    it "tries to parse service using URI.parse" do
      URI.should_receive(:parse).with('http://example.com')

      service_ticket = ServiceTicket.new(:service => 'http://example.com')
      service_ticket.service_uri
    end

    describe "when the service has an existing querystring" do

      it "appends the ticket to the service querystring" do
        service_ticket = ServiceTicket.new(:service => 'http://example.com?foo=bar', :ticket => 'my_ticket')
        service_ticket.service_uri.should == "http://example.com?foo=bar&ticket=my_ticket"
      end

    end

    describe "when the service has no querystring" do

      it "adds a querystring containing the ticket to the service" do
        service_ticket = ServiceTicket.new(:service => 'http://example.com', :ticket => 'my_ticket')
        service_ticket.service_uri.should == "http://example.com?ticket=my_ticket"
      end

    end

    describe "when the service has a querystring of '?' only" do

      it "removes the question mark" do
        service_ticket = ServiceTicket.new(:service => 'http://example.com?', :ticket => 'my_ticket')
        service_ticket.service_uri.should == "http://example.com?ticket=my_ticket"
      end

    end

    describe "when you give an invalid URI" do

      it "handles the URI::InvalidURIError" do
        URI.should_receive(:parse).and_raise(URI::InvalidURIError)

        service_ticket = ServiceTicket.new(:service => 'invalid uri here', :ticket => 'my_ticket')
        service_ticket.service_uri
      end

      it "returns nil" do
        service_ticket = ServiceTicket.new(:service => 'invalid uri here', :ticket => 'my_ticket')
        service_ticket.service_uri.should be_nil
      end

    end

  end

  describe "generate ticket for" do

    it "delegates to create!" do
      ticket = TicketGrantingTicket.new :username => 'foo'

      ServiceTicket.should_receive(:create!).with(:service => 'service', :client_hostname => 'client_host', :username => 'foo', :ticket_granting_ticket => ticket)

      ServiceTicket.generate_ticket_for('service', 'client_host', ticket)
    end

  end

  describe "matching service?" do

    it "matches if the given service is equal to the ticket's service" do
      service_ticket = Castronaut::Models::ServiceTicket.new(:service => 'http://foo')
      service_ticket.matches_service?('foo').should be_false
      service_ticket.matches_service?('http://foo').should be_true
      service_ticket.matches_service?('http://foo/').should be_false
    end

  end

  describe "validating ticket" do

    describe "when the service and ticket are missing returns a ticket result" do

      it "with the missing ticket message" do
        Castronaut::Models::ServiceTicket.validate_ticket(nil, nil).message.should == Castronaut::Models::ServiceTicket::MissingMessage
      end

      it "with the INVALID_REQUEST message category" do
        Castronaut::Models::ServiceTicket.validate_ticket(nil, nil).message_category.should == 'INVALID_REQUEST'
      end

      it "is marked as invalid" do
        Castronaut::Models::ServiceTicket.validate_ticket(nil, nil).should be_invalid
      end

    end

    describe "when the service and ticket are given" do

      it "attempts to find the ServiceTicket by the given ticket" do
        Castronaut::Models::ServiceTicket.should_receive(:find_by_ticket).with('ticket').and_return(stub_everything)
        Castronaut::Models::ServiceTicket.validate_ticket('service', 'ticket')
      end

      describe "when it fails to find a service ticket returns a ticket result" do

        it "with the ticket not recognized message" do
          Castronaut::Models::ServiceTicket.stub!(:find_by_ticket).and_return(nil)
          Castronaut::Models::ServiceTicket.validate_ticket('service', 'ticket').message.should == "Ticket ticket not recognized."
        end

        it "with the INVALID_TICKET message category" do
          Castronaut::Models::ServiceTicket.stub!(:find_by_ticket).and_return(nil)
          Castronaut::Models::ServiceTicket.validate_ticket('service', 'ticket').message_category.should == 'INVALID_TICKET'
        end

        it "is marked as invalid" do
          Castronaut::Models::ServiceTicket.stub!(:find_by_ticket).and_return(nil)
          Castronaut::Models::ServiceTicket.validate_ticket('service', 'ticket').should be_invalid
        end

      end

      describe "when it finds a service ticket" do

        describe "when it is already consumed it returns a ticket result" do

          it "with the ticket used up message" do
            Castronaut::Models::ServiceTicket.stub!(:find_by_ticket).and_return(stub_everything(:consumed? => true))
            Castronaut::Models::ServiceTicket.validate_ticket('service', 'ticket').message.should == "Ticket 'ticket' has already been used up."
          end

          it "with the INVALID_TICKET message category" do
            Castronaut::Models::ServiceTicket.stub!(:find_by_ticket).and_return(stub_everything(:consumed? => true))
            Castronaut::Models::ServiceTicket.validate_ticket('service', 'ticket').message_category.should == 'INVALID_TICKET'
          end

          it "is marked as invalid" do
            Castronaut::Models::ServiceTicket.stub!(:find_by_ticket).and_return(stub_everything(:consumed? => true))
            Castronaut::Models::ServiceTicket.validate_ticket('service', 'ticket').should be_invalid
          end

        end

        describe "when it has not been consumed" do

          it "consumes the service ticket" do
            service_ticket = stub_model(ServiceTicket, :consumed? => false)
            service_ticket.should_receive(:consume!)

            Castronaut::Models::ServiceTicket.stub!(:find_by_ticket).and_return(service_ticket)
            Castronaut::Models::ServiceTicket.validate_ticket('service', 'ticket')
          end

          describe "when it encounters a proxy ticket it returns a ticket result" do

            it "with the ticket is a proxy ticket message" do
              service_ticket = stub_model(ServiceTicket, :consumed? => false, :consume! => nil)
              service_ticket.stub!(:===).and_return(true)
              Castronaut::Models::ServiceTicket.stub!(:find_by_ticket).and_return(service_ticket)

              Castronaut::Models::ServiceTicket.validate_ticket('service', 'ticket', false).message.should == "Ticket 'ticket' is a proxy ticket, but only service tickets are allowed here."
            end

            it "with the INVALID_TICKET message category" do
              service_ticket = stub_model(ServiceTicket, :consumed? => false, :consume! => nil)
              service_ticket.stub!(:===).and_return(true)
              Castronaut::Models::ServiceTicket.stub!(:find_by_ticket).and_return(service_ticket)

              Castronaut::Models::ServiceTicket.validate_ticket('service', 'ticket', false).message_category.should == "INVALID_TICKET"
            end

            it "is marked as invalid" do
              service_ticket = stub_model(ServiceTicket, :consumed? => false, :consume! => nil)
              service_ticket.stub!(:===).and_return(true)
              Castronaut::Models::ServiceTicket.stub!(:find_by_ticket).and_return(service_ticket)

              Castronaut::Models::ServiceTicket.validate_ticket('service', 'ticket', false).should be_invalid
            end

          end

          describe "when it is already expired it returns a ticket result" do
            
            before do
              Castronaut::Models::ServiceTicket.stub!(:find_by_ticket).and_return(stub_model(ServiceTicket, :expired? => true, :consumed? => false, :consumed_at= => nil, :save! => nil))
            end

            it "with the ticket expired message" do
              Castronaut::Models::ServiceTicket.validate_ticket('service', 'ticket').message.should == "Ticket 'ticket' has expired."
            end

            it "with the INVALID_TICKET message category" do
              Castronaut::Models::ServiceTicket.validate_ticket('service', 'ticket').message_category.should == 'INVALID_TICKET'
            end

            it "is marked as invalid" do
              Castronaut::Models::ServiceTicket.validate_ticket('service', 'ticket').should be_invalid
            end

          end

          describe "when it encounters a mismatched service it returns a ticket result" do

            before do
              Castronaut::Models::ServiceTicket.stub!(:find_by_ticket).and_return(stub_model(ServiceTicket, :expired? => false, :consumed? => false, :consumed_at= => nil, :service => 'my service', :save! => nil))              
            end

            it "with the service mismatch message" do
              Castronaut::Models::ServiceTicket.validate_ticket('service', 'ticket').message.should include("does not match the service")
            end

            it "with the INVALID_SERVICE message category" do
              Castronaut::Models::ServiceTicket.validate_ticket('service', 'ticket').message_category.should == 'INVALID_SERVICE'
            end

            it "is marked as invalid" do
              Castronaut::Models::ServiceTicket.validate_ticket('service', 'ticket').should be_invalid
            end

          end

          
        end
      

        describe "when ticket validation was successful and no branches were encountered" do
          
          before do
            Castronaut::Models::ServiceTicket.stub!(:find_by_ticket).and_return(mock('service ticket', :consumed? => false, :expired? => false, :consumed_at= => nil, :null_object => true, :matches_service? => true))
          end

          it "returns a ticket result with a nil message" do
            Castronaut::Models::ServiceTicket.validate_ticket('service', 'ticket').message.should be_nil
          end

          it "returns a ticket result with a message category of 'success'" do
            Castronaut::Models::ServiceTicket.validate_ticket('service', 'ticket').message_category.should == 'success'
          end

          it "returns a valid ticket result" do
            Castronaut::Models::ServiceTicket.validate_ticket('service', 'ticket').should be_valid
          end

        end

      end

    end

  end

end
