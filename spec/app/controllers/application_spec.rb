require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_controller_helper'))
require 'spec/interop/test'

describe 'Castronaut Application Controller' do

  describe "requesting / via GET" do

    it "redirects to /login" do
      get_it '/'

      should be_redirection
    end

  end

  describe "requesting /login via GET" do

    it "responds with status 200" do
      get_it '/login', :env => { 'REMOTE_ADDR' => '10.0.0.1' }

      should be_ok
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
      now = Time.parse("01/01/2008")
      Time.stub!(:now).and_return(now)

      get_it '/login', :env => { 'REMOTE_ADDR' => '10.0.0.1' }

      headers['Expires'].should == "Wed, 01 Jan 2003 00:00:00 -0500"
    end

    xit "gets the service from params[:service]"

    xit "gets renewal? from params[:renew]"

    xit "determines if this is a gateway? from params[:gateway]"

    describe "when you have a ticket generating ticket cookie" do

      xit "validates it using the ticket generating ticket validator"

      xit "returns the validator object"

      xit "returns whether or not an error occured during validation"

      describe "when there was an error validating" do

        xit "sets a display message for the view"

      end

    end

    describe "when a redirection loop is detected" do

      it "sets a display message for the view" do
        get_it '/login', 'redirection_loop_intercepted' => 'any old thing', :env => { 'REMOTE_ADDR' => '10.0.0.1' }
        
        body.should include("The client and server are unable to negotiate authentication.")
      end

    end

  end

  describe "requesting /login via POST" do

    it 'responds with status 200' do
      post_it '/login', :env => { 'REMOTE_ADDR' => '10.0.0.1' }

      should be_ok
    end

  end

  describe "requesting /validate via GET" do

    it 'responds with status 200' do
      get_it '/validate', :env => { 'REMOTE_ADDR' => '10.0.0.1' }

      should be_ok
    end

  end

  describe "requesting /serviceValidate via GET" do

    it 'responds with status 200' do
      get_it '/serviceValidate', :env => { 'REMOTE_ADDR' => '10.0.0.1' }

      should be_ok
    end

  end

end

