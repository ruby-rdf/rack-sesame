require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'Rack::Sesame::VERSION' do
  it "should match the VERSION file" do
    Rack::Sesame::VERSION.to_s.should == File.read(File.join(File.dirname(__FILE__), '..', 'VERSION')).chomp
  end
end
