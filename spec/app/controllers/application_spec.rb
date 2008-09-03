require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_controller_helper'))
require 'spec/interop/test'
 
describe 'Castronaut Application Controller' do
  
  it 'handles GET requests to /' do
    get_it '/'
    
    @response.status.should == 200
  end
  
  it 'handles GET requests to /login' do
    get_it '/login'
    
    @response.status.should == 200
  end
  
  it 'handles POST requests to /login' do
    post_it '/login'
    
    @response.status.should == 200
  end

  it 'handles GET requests to /validate' do
    get_it '/validate'
    
    @response.status.should == 200
  end
  
  it 'handles GET requests to /serviceValidate' do
    get_it '/serviceValidate'
    
    @response.status.should == 200
  end
  
  it 'handles GET requests to /loginTicket' do
    get_it '/loginTicket'
    
    @response.status.should == 200
  end
  
  it 'handles POST requests to /loginTicket' do
    post_it '/loginTicket'
    
    @response.status.should == 200
  end
  
end
 
