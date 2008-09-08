require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

describe Castronaut::Presenters::ProcessLogin do
  
  before do
    @controller = mock('controller')
    @controller.stubs(:params).returns({ })
    @controller.stubs(:request).returns(stub(:cookies => {}, :env => { 'REMOTE_ADDR' => '10.1.1.1' }))
    @controller.stubs(:erb)
  end

  describe "initialization" do

    it "exposes the given controller at :controller" do
      Castronaut::Presenters::ProcessLogin.new(@controller).controller.should == @controller
    end

  end

  it "gets :service out of params['service']" do
    @controller.params['service'] = 'usefulService2'
    Castronaut::Presenters::ProcessLogin.new(@controller).service.should == 'usefulService2'
  end

  it "gets :renewal out of params['renew']" do
    @controller.params['renew'] = 'iWantToRenew'
    Castronaut::Presenters::ProcessLogin.new(@controller).renewal.should == 'iWantToRenew'
  end

  describe "gateway?" do

    it "returns true if params['gateway'] is '1'" do
      @controller.params['gateway'] = '1'
      Castronaut::Presenters::ProcessLogin.new(@controller).should be_gateway
    end

    it "returns true if params['gateway'] is 'true'" do
      @controller.params['gateway'] = 'true'
      Castronaut::Presenters::ProcessLogin.new(@controller).should be_gateway
    end

  end

  it "gets :ticket_generating_ticket_cookie from request.cookies['tgt']" do
    @controller.request.cookies['tgt'] = 'fake cookie'
    Castronaut::Presenters::ProcessLogin.new(@controller).ticket_generating_ticket_cookie.should == 'fake cookie'
  end

end
