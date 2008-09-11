require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

include Castronaut::Models

describe Castronaut::Models::ProxyTicket do

  it "has a ticket prefix of PT" do
    ProxyTicket.new.ticket_prefix.should == 'PT'
  end

  describe "validating ticket" do

    it "validates the service and ticket using the service ticket validator" do
      ServiceTicket.expects(:validate_ticket).with('service', 'ticket', true).returns(stub_everything(:invalid? => true))
      ProxyTicket.validate_ticket('service', 'ticket')
    end

    describe "when the service ticket result is invalid" do

      it "returns the service ticket result directly" do
        ticket_result = stub_everything(:invalid? => true)
        ServiceTicket.stubs(:validate_ticket).returns(ticket_result)
        
        ProxyTicket.validate_ticket('service', 'ticket').should == ticket_result
      end

    end

    describe "when the service ticket result is valid and the ticket is a proxy ticket" do

      describe "when the proxy granting ticket is nil it returns a ticket result" do

        it "with a proxy ticket not associated to a proxy granting ticket message" do
          ticket_result = stub_everything(:invalid? => false, :username => 'bob', :ticket => stub_everything(:=== => true, :to_s => 'PT', :proxy_granting_ticket => nil))
          ServiceTicket.stubs(:validate_ticket).returns(ticket_result)
          
          ProxyTicket.validate_ticket('service', 'ticket').message.should == "Proxy ticket 'PT' belonging to user 'bob' is not associated with a proxy granting ticket."
        end

        it "with the INTERNAL_ERROR message category" do
          ticket_result = stub_everything(:invalid? => false, :username => 'bob', :ticket => stub_everything(:=== => true, :to_s => 'PT', :proxy_granting_ticket => nil))
          ServiceTicket.stubs(:validate_ticket).returns(ticket_result)
          
          ProxyTicket.validate_ticket('service', 'ticket').message_category.should == "INTERNAL_ERROR"
        end

        it "is marked as invalid" do
          ticket_result = stub_everything(:invalid? => false, :username => 'bob', :ticket => stub_everything(:=== => true, :to_s => 'PT', :proxy_granting_ticket => nil))
          ServiceTicket.stubs(:validate_ticket).returns(ticket_result)
          
          ProxyTicket.validate_ticket('service', 'ticket').should be_invalid
        end

      end

      describe "when the proxy granting ticket's service ticket is nil it returns a ticket result" do

        it "with a proxy granting ticket is not associated to a service ticket message" do
          ticket_result = stub_everything(:invalid? => false, :username => 'bob', :ticket => stub_everything(:=== => true, :to_s => 'PT', :proxy_granting_ticket => stub_everything(:service_ticket => nil, :to_s => 'PGT')))
          ServiceTicket.stubs(:validate_ticket).returns(ticket_result)
          
          ProxyTicket.validate_ticket('service', 'ticket').message.should == "Proxy granting ticket 'PGT' (associated with proxy ticket 'PT' and belonging to user 'bob' is not associated with a service ticket."
        end

        it "with the INTERNAL_ERROR message category" do
          ticket_result = stub_everything(:invalid? => false, :username => 'bob', :ticket => stub_everything(:=== => true, :to_s => 'PT', :proxy_granting_ticket => stub_everything(:service_ticket => nil)))
          ServiceTicket.stubs(:validate_ticket).returns(ticket_result)
          
          ProxyTicket.validate_ticket('service', 'ticket').message_category.should == "INTERNAL_ERROR"
        end

        it "is marked as invalid" do
          ticket_result = stub_everything(:invalid? => false, :username => 'bob', :ticket => stub_everything(:=== => true, :to_s => 'PT', :proxy_granting_ticket => stub_everything(:service_ticket => nil)))
          ServiceTicket.stubs(:validate_ticket).returns(ticket_result)
          
          ProxyTicket.validate_ticket('service', 'ticket').should be_invalid
        end

      end

    end

  end

end
