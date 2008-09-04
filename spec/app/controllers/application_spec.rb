require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_controller_helper'))
require 'spec/interop/test'
 
describe 'Castronaut Application Controller' do
  
  it 'handles GET requests to /' do
    get_it '/'
    
    status.should == 200
  end
  
  describe "requesting /login via GET" do
  
    it "responds with status 200" do
      get_it '/login'
      
      status.should == 200
    end
    
    it "sets the Pragma header to 'no-cache'" do
      get_it '/login'
      
      headers['Pragma'].should == 'no-cache'
    end

    it "sets the Cache-Control header to 'no-store'" do
      get_it '/login'
      
      headers['Cache-Control'].should == 'no-store'
    end
    
    it "sets the Expires header to '5 years ago in rfc2822 format'" do
      now = Time.parse("01/01/2008")
      Time.stubs(:now).returns(now)
      
      get_it '/login'
      
      headers['Expires'].should == "Wed, 01 Jan 2003 00:00:00 -0500"
    end
    
  end
    
  it 'handles POST requests to /login' do
    post_it '/login'
    
    status.should == 200
  end

  it 'handles GET requests to /validate' do
    get_it '/validate'
    
    status.should == 200
  end
  
  it 'handles GET requests to /serviceValidate' do
    get_it '/serviceValidate'
    
    status.should == 200
  end
  
  it 'handles GET requests to /loginTicket' do
    get_it '/loginTicket'
    
    status.should == 200
  end
  
  it 'handles POST requests to /loginTicket' do
    post_it '/loginTicket'
    
    status.should == 200
  end
  
end
 
