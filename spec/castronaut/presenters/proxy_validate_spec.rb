require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

describe Castronaut::Presenters::ProxyValidate do

  before do
    @controller = stub('controller', :params => {}, :erb => nil, :request => stub('request', :cookies => {}, :env => { 'REMOTE_ADDR' => '10.1.1.1'}))
  end

  describe "initialization" do

      it "exposes the given controller at :controller" do
        Castronaut::Presenters::ProxyValidate.new(@controller).controller.should == @controller
      end

    end

    it "gets :service out of params['service']" do
      @controller.params['service'] = 'usefulService2'
      Castronaut::Presenters::ProxyValidate.new(@controller).service.should == 'usefulService2'
    end

    it "gets :renewal out of params['renew']" do
      @controller.params['renew'] = 'iWantToRenew'
      Castronaut::Presenters::ProxyValidate.new(@controller).renewal.should == 'iWantToRenew'
    end

    it "gets :ticket out of params['ticket']" do
      @controller.params['ticket'] = 'my-ticket'
      Castronaut::Presenters::ProxyValidate.new(@controller).ticket.should == 'my-ticket'
    end

    it "gets :proxy_granting_ticket_url out of params['pgtUrl']" do
      @controller.params['pgtUrl'] = 'http://example.com/'

      Castronaut::Presenters::ProxyValidate.new(@controller).proxy_granting_ticket_url.should == 'http://example.com/'
    end

    describe "represent!" do

      it "validates the proxy ticket" do
        @controller.params['service'] = 'http://example.com'
        @controller.params['ticket'] = 'footicket'
        Castronaut::Models::ProxyTicket.should_receive(:validate_ticket).with('http://example.com', 'footicket').and_return(stub(:valid? => false).as_null_object)
        Castronaut::Presenters::ProxyValidate.new(@controller).represent!
      end

      describe "when the parameters are valid" do

        before do
          @controller.params['service'] = 'http://example.com'
          @controller.params['ticket'] = 'footicket'
        end

        it "exposes the proxy ticket result as :proxy_ticket_result" do
          proxy_ticket_result = stub(:valid? => false, :ticket_granting_ticket => stub({}).as_null_object).as_null_object
          Castronaut::Models::ProxyTicket.should_receive(:validate_ticket).and_return(proxy_ticket_result)
          Castronaut::Presenters::ProxyValidate.new(@controller).represent!.proxy_ticket_result.should == proxy_ticket_result
        end
        
        it "exposes the service ticket username as :username" do
          Castronaut::Models::ProxyTicket.should_receive(:validate_ticket).and_return(stub('ticket result', :proxies => nil, :valid? => true, :username => 'bubba'))
          Castronaut::Presenters::ProxyValidate.new(@controller).represent!.username.should == 'bubba'
        end

        describe "when the proxy ticket result is a proxy ticket" do
          
          it "creates an array of proxies from the proxy ticket results service ticket service" do
            service_ticket = stub(:service => 'http://myservice.com').as_null_object
            Castronaut::Models::ProxyTicket.should_receive(:validate_ticket).and_return(stub(:valid? => true, :service_ticket => service_ticket).as_null_object)
            Castronaut::Presenters::ProxyValidate.new(@controller).represent!
          end

        end

        describe "when a proxy granting ticket url is present" do

          it "attempts to generate a proxy granting ticket" do
            @controller.params['pgtUrl'] = 'http://proxygrantingticketurl'
            Castronaut::Models::ProxyTicket.stub!(:validate_ticket).and_return(stub(:valid? => true, :ticket => 'service ticket', :ticket_granting_ticket => stub({}).as_null_object).as_null_object)

            Castronaut::Models::ProxyGrantingTicket.should_receive(:generate_ticket).with('http://proxygrantingticketurl', '10.1.1.1', anything).and_return(stub({}).as_null_object)
            Castronaut::Presenters::ProxyValidate.new(@controller).represent!
          end

          describe "when proxy granting ticket generation succeeds" do

            it "gets :proxy_granting_ticket_iou from the proxy_granting_ticket_result" do
              @controller.params['pgtUrl'] = 'http://proxygrantingticketurl'
              Castronaut::Models::ProxyTicket.stub!(:validate_ticket).and_return(stub('ticket result', :proxies => nil, :valid? => true, :ticket => 'service ticket', :ticket_granting_ticket => stub({}).as_null_object))
              Castronaut::Models::ProxyGrantingTicket.stub!(:generate_ticket).and_return(stub('proxy granting ticket result', :iou => 'pgtiou'))

              Castronaut::Presenters::ProxyValidate.new(@controller).represent!.proxy_granting_ticket_iou.should == 'pgtiou'
            end

          end

        end

      end

    end

end
