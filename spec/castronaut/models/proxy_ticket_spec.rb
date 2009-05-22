require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

include Castronaut::Models

describe Castronaut::Models::ProxyTicket do

  it "has a ticket prefix of PT" do
    ProxyTicket.new.ticket_prefix.should == 'PT'
  end
  
  it "builds a list of proxies by asking the proxy granting ticket for it's service ticket service" do
    proxy_ticket = stub_model(ProxyTicket, :proxy_granting_ticket => stub_model(ProxyGrantingTicket, :service_ticket => stub_model(ServiceTicket, :service => 'my service')))
    proxy_ticket.proxies.should == ['my service']
  end
  
  describe "validating ticket" do

    it "validates the service and ticket using the service ticket validator" do
      ServiceTicket.should_receive(:validate_ticket).with('service', 'ticket', true).and_return(stub(:invalid? => true).as_null_object)
      ProxyTicket.validate_ticket('service', 'ticket')
    end

    describe "when the service ticket result is invalid" do

      it "and_return the service ticket result directly" do
        ticket_result = stub('ticket result', :invalid? => true)
        ServiceTicket.stub!(:validate_ticket).and_return(ticket_result)
        
        ProxyTicket.validate_ticket('service', 'ticket').should == ticket_result
      end

    end

    describe "when the service ticket result is valid and the ticket is a proxy ticket" do

      describe "when the proxy granting ticket is nil it and_return a ticket result" do

        before do
          ticket_result = stub('ticket_result', :invalid? => false, :username => 'bob', :ticket => stub('ticket', :=== => true, :to_s => 'PT', :proxy_granting_ticket => nil))
          ServiceTicket.stub!(:validate_ticket).and_return(ticket_result)
        end

        it "with a proxy ticket not associated to a proxy granting ticket message" do
          ProxyTicket.validate_ticket('service', 'ticket').message.should == "Proxy ticket 'PT' belonging to user 'bob' is not associated with a proxy granting ticket."
        end

        it "with the INTERNAL_ERROR message category" do
          ProxyTicket.validate_ticket('service', 'ticket').message_category.should == "INTERNAL_ERROR"
        end

        it "is marked as invalid" do
          ProxyTicket.validate_ticket('service', 'ticket').should be_invalid
        end

      end

      describe "when the proxy granting ticket's service ticket is nil it and_return a ticket result" do
        
        before do
          ticket_result = stub('ticket_result', :invalid? => false, :username => 'bob', :ticket => stub('ticket', :=== => true, 
                                                :to_s => 'PT', :proxy_granting_ticket => stub('pgt', :service_ticket => nil, :to_s => 'PGT')))
          ServiceTicket.stub!(:validate_ticket).and_return(ticket_result)
        end

        it "with a proxy granting ticket is not associated to a service ticket message" do
          ProxyTicket.validate_ticket('service', 'ticket').message.should == "Proxy granting ticket 'PGT' (associated with proxy ticket 'PT' and belonging to user 'bob' is not associated with a service ticket."
        end

        it "with the INTERNAL_ERROR message category" do
          ProxyTicket.validate_ticket('service', 'ticket').message_category.should == "INTERNAL_ERROR"
        end

        it "is marked as invalid" do
          ProxyTicket.validate_ticket('service', 'ticket').should be_invalid
        end

      end

    end
    
    describe "when the service ticket result is valid" do

      it "returns a ticket result with the service results ticket" do
        ticket_result = stub('ticket result', :invalid? => false, :ticket => "STUB")
        ServiceTicket.stub!(:validate_ticket).and_return(ticket_result)
        
        ProxyTicket.validate_ticket('service', 'ticket').ticket.should == "STUB"
      end

      it "returns a ticket result with the 'success' message category" do
        ticket_result = stub('ticket result', :invalid? => false, :ticket => "STUB")
        ServiceTicket.stub!(:validate_ticket).and_return(ticket_result)
        
        ProxyTicket.validate_ticket('service', 'ticket').message_category.should == 'success'
      end


      it "returns a ticket result that is valid" do
        ticket_result = stub('ticket result', :invalid? => false, :ticket => "STUB")
        ServiceTicket.stub!(:validate_ticket).and_return(ticket_result)
        
        ProxyTicket.validate_ticket('service', 'ticket').should be_valid
      end

    end

  end

end
