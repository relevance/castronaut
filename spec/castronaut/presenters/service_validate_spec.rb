require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

describe Castronaut::Presenters::ServiceValidate do

  before do
    @controller = mock('controller')
    @controller.stubs(:params).returns({ })
    @controller.stubs(:request).returns(stub(:cookies => {}, :env => { 'REMOTE_ADDR' => '10.1.1.1' }))
    @controller.stubs(:erb)
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
        Castronaut::Models::ServiceTicket.expects(:validate_ticket).with('http://example.com', 'footicket').returns(stub_everything(:valid? => false))
        Castronaut::Presenters::ServiceValidate.new(@controller).represent!
      end

      describe "when the parameters are valid" do
        
        before do
          @controller.params['service'] = 'http://example.com'
          @controller.params['ticket'] = 'footicket'
        end
        
        it "exposes the service ticket username as :username" do
          Castronaut::Models::ServiceTicket.expects(:validate_ticket).returns(stub_everything(:valid? => true, :username => 'bubba'))
          Castronaut::Presenters::ServiceValidate.new(@controller).represent!.username.should == 'bubba'
        end
        
        it "exposes the extra attributes" do
          Castronaut::Models::ServiceTicket.expects(:validate_ticket).returns(stub_everything(:valid? => false, :ticket_granting_ticket => stub_everything(:extra_attributes => 'foobar hash')))
          Castronaut::Presenters::ServiceValidate.new(@controller).represent!.extra_attributes == 'foobar hash'
        end
        
        describe "when a proxy granting ticket url is present" do
          
          it "attempts to generate a proxy granting ticket" do
            @controller.params['pgtUrl'] = 'http://proxygrantingticketurl'
            Castronaut::Models::ServiceTicket.stubs(:validate_ticket).returns(stub_everything(:valid? => true, :ticket => 'service ticket', :ticket_granting_ticket => stub_everything(:extra_attributes => 'foobar hash')))
            
            Castronaut::Models::ProxyGrantingTicket.expects(:generate_ticket).with('http://proxygrantingticketurl', '10.1.1.1', 'service ticket').returns(stub_everything)
            Castronaut::Presenters::ServiceValidate.new(@controller).represent!            
          end
          
          describe "when proxy granting ticket generation succeeds" do
            
            it "exposes proxy granting ticket iou as :iou"
          
          end
          
        end
       
      end

    end
  
end
