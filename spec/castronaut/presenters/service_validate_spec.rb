require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

describe Castronaut::Presenters::ServiceValidate do

  before do
    @controller = stub('controller', :params => {}, :erb => nil, :request => stub('request', :cookies => {}, :env => { 'REMOTE_ADDR' => '10.1.1.1'}))
  end

  describe "initialization" do

    it "exposes the given controller at :controller" do
      Castronaut::Presenters::ServiceValidate.new(@controller).controller.should == @controller
    end

  end

  it "gets :service out of params['service']" do
    @controller.params['service'] = 'usefulService2'
    Castronaut::Presenters::ServiceValidate.new(@controller).service.should == 'usefulService2'
  end

  it "gets :renewal out of params['renew']" do
    @controller.params['renew'] = 'iWantToRenew'
    Castronaut::Presenters::ServiceValidate.new(@controller).renewal.should == 'iWantToRenew'
  end

  it "gets :ticket out of params['ticket']" do
    @controller.params['ticket'] = 'my-ticket'
    Castronaut::Presenters::ServiceValidate.new(@controller).ticket.should == 'my-ticket'
  end

  it "gets :proxy_granting_ticket_url out of params['pgtUrl']" do
    @controller.params['pgtUrl'] = 'http://example.com/'
    Castronaut::Presenters::ServiceValidate.new(@controller).proxy_granting_ticket_url.should == 'http://example.com/'
  end

  it "gets :proxy_granting_ticket_iou from the proxy_granting_ticket_result when present"

  describe "represent!" do

    it "validates the service ticket" do
      @controller.params['service'] = 'http://example.com'
      @controller.params['ticket'] = 'footicket'
      Castronaut::Models::ServiceTicket.should_receive(:validate_ticket).with('http://example.com', 'footicket').and_return(stub_everything(:valid? => false))
      Castronaut::Presenters::ServiceValidate.new(@controller).represent!
    end

    describe "when the parameters are valid" do

      before do
        @controller.params['service'] = 'http://example.com'
        @controller.params['ticket'] = 'footicket'
      end

      it "exposes the service ticket username as :username" do
        Castronaut::Models::ServiceTicket.should_receive(:validate_ticket).and_return(stub('ticket result', :valid? => true, :username => 'bubba'))
        Castronaut::Presenters::ServiceValidate.new(@controller).represent!.username.should == 'bubba'
      end

      describe "when a proxy granting ticket url is present" do

        it "attempts to generate a proxy granting ticket" do
          @controller.params['pgtUrl'] = 'http://proxygrantingticketurl'
          Castronaut::Models::ServiceTicket.stub!(:validate_ticket).and_return(stub('ticket result', :valid? => true, :ticket => 'service ticket', :ticket_granting_ticket => stub('tgt')))

          Castronaut::Models::ProxyGrantingTicket.should_receive(:generate_ticket).with('http://proxygrantingticketurl', '10.1.1.1', 'service ticket').and_return(stub_everything)
          Castronaut::Presenters::ServiceValidate.new(@controller).represent!
        end

        describe "when proxy granting ticket generation succeeds" do

          it "gets :proxy_granting_ticket_iou from the proxy_granting_ticket_result" do
            @controller.params['pgtUrl'] = 'http://proxygrantingticketurl'
            Castronaut::Models::ServiceTicket.stub!(:validate_ticket).and_return(stub('ticket result', :proxies => nil, :valid? => true, :ticket => 'service ticket', :ticket_granting_ticket => stub_everything))
            Castronaut::Models::ProxyGrantingTicket.stub!(:generate_ticket).and_return(stub('proxy granting ticket result', :iou => 'pgtiou'))

            Castronaut::Presenters::ServiceValidate.new(@controller).represent!.proxy_granting_ticket_iou.should == 'pgtiou'
          end

        end

      end

    end

  end

end
