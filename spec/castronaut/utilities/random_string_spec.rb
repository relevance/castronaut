require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

describe Castronaut::Utilities::RandomString do

  it "generates random string with a given length using ISAAC" do
    isaac = stub(:rand => "123")
    ::Crypt::ISAAC.expects(:new).returns(isaac)
    isaac.expects(:rand).with(4_294_619_050).returns("123")
    Castronaut::Utilities::RandomString.generate
  end

end
