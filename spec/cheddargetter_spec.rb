require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "an instance of CheddarGetter" do
  before(:all) do
    @product_code = "MY_PRODUCT"
    @cheddar_getter = CheddarGetter.new(@product_code)
  end
  
  describe 'calling #plans' do
    before(:all) do
      mock_request(:get, "/plans/get/productCode/#{@product_code}", :body => "<plans><plan>my plan</plan></plans>")
    end
    
    it "should return the plans in a hash" do
      flunk @cheddar_getter.plans.inspect
    end
  end
  
  def mock_request(method, path, options = nil)
    path.gsub!(/^\//, '')
    FakeWeb.register_uri(method, "https://cheddargetter.com/xml/#{path}", options)
  end
end
