require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_controller_helper'))
require 'spec/interop/test'

describe 'Castronaut Application Controller' do

  describe "requesting / via GET" do
    it "redirects to /login" do
      get_it '/'
      @response.should be_redirection
    end
  end

  describe "requesting /login via GET" do

    it "responds with status 200" do
      get_it '/login', :env => { 'REMOTE_ADDR' => '10.0.0.1' }

      @response.should be_ok
    end

    it "sets the Pragma header to 'no-cache'" do
      get_it '/login', :env => { 'REMOTE_ADDR' => '10.0.0.1' }

      headers['Pragma'].should == 'no-cache'
    end

    it "sets the Cache-Control header to 'no-store'" do
      get_it '/login', :env => { 'REMOTE_ADDR' => '10.0.0.1' }

      headers['Cache-Control'].should == 'no-store'
    end

    it "sets the Expires header to '5 years ago in rfc2822 format'" do
      jan_1st_2008 = Time.parse("01/01/2008 00:00:00")
      jan_1st_2003 = Time.parse("01/01/2003 00:00:00")
      Time.stub!(:now).and_return(jan_1st_2008)
      
      get_it '/login', :env => { 'REMOTE_ADDR' => '10.0.0.1' }

      headers['Expires'].should include("Wed, 01 Jan 2003 00:00:00")
    end

  end

  describe "requesting /login via POST" do

    it 'responds with status 200' do
      post_it '/login', :env => { 'REMOTE_ADDR' => '10.0.0.1' }

      @response.should be_ok
    end

  end

  describe "requesting /logout via GET" do

    it 'responds with status 200' do
      get_it '/logout', :env => { 'REMOTE_ADDR' => '10.0.0.1' }

      @response.should be_ok
    end

  end

  describe "requesting /serviceValidate via GET" do

    it 'responds with status 200' do
      get_it '/serviceValidate', :env => { 'REMOTE_ADDR' => '10.0.0.1' }

      @response.should be_ok
    end

  end
  
  describe "requesting /proxyValidate via GET" do

    it 'responds with status 200' do
      get_it '/proxyValidate', :env => { 'REMOTE_ADDR' => '10.0.0.1' }

      @response.should be_ok
    end

  end

end

