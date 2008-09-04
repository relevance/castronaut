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
      get_it '/login'
      
      should be_ok
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
  
  describe "requesting /login via POST" do  

    it 'responds with status 200' do
      post_it '/login'
    
      should be_ok
    end

  end

  describe "requesting /validate via GET" do  

    it 'responds with status 200' do
      get_it '/validate'
    
      should be_ok
    end
  
  end
  
  describe "requesting /serviceValidate via GET" do  

    it 'responds with status 200' do
      get_it '/serviceValidate'
    
      should be_ok
    end
    
  end
  
  describe "requesting /loginTicket via GET" do  

    it 'responds with status 200' do
      get_it '/loginTicket'
    
      should be_ok
    end

  end  
  
  describe "requesting /loginTicket via POST" do  

    it 'responds with status 200' do
      post_it '/loginTicket'
    
      should be_ok
    end
  
  end
  
end
 
