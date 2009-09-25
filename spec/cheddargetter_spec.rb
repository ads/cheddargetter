require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "an instance of CheddarGetter" do
  before(:all) do
    CheddarGetter.stub!(:basic_auth)
    @cheddar_getter = CheddarGetter.new('my_username', 'my_password', 'MY_PRODUCT')
  end
  
  it "should use the supplied username and password for basic auth" do
    CheddarGetter.should_receive(:basic_auth).with('my_username', 'my_password')
    CheddarGetter.new('my_username', 'my_password', 'MY_PRODUCT')
  end
  
  describe 'calling #plans' do
    it "should return an empty array if there are no plans" do
      mock_request(:get, "/plans/get/productCode/MY_PRODUCT", "<plans></plans>")
      @cheddar_getter.plans.should == []
    end

    it "should return the plan in an array if there is one plan" do
      mock_request(:get, "/plans/get/productCode/MY_PRODUCT", "<plans><plan>plan1</plan></plans>")
      plans = @cheddar_getter.plans
      plans.length.should == 1
      plans.should include('plan1')
    end
    
    it "should return the plans in an array if there are multiple plans" do
      mock_request(:get, "/plans/get/productCode/MY_PRODUCT", "<plans><plan>plan1</plan><plan>plan2</plan></plans>")
      plans = @cheddar_getter.plans
      plans.length.should == 2
      plans.should include('plan1')
      plans.should include('plan2')
    end

    it "should raise if an error is returned" do
      mock_request(:get, "/plans/get/productCode/MY_PRODUCT", "<error>the message</error>")
      lambda { @cheddar_getter.plans }.should raise_error(CheddarGetter::Error, 'the message')
    end
  end
  
  describe 'calling #plan(plan_code)' do
    it "should return the requested plan if the plan code is valid" do
      (1..3).each do |i|
        mock_request(:get, "/plans/get/productCode/MY_PRODUCT/code/MY_PLAN#{i}", "<plans><plan>plan#{i}</plan></plans>")
        @cheddar_getter.plan("MY_PLAN#{i}").should == "plan#{i}"
      end
    end
    
    it "should raise if the plan code is not valid" do
      mock_request(:get, "/plans/get/productCode/MY_PRODUCT/code/BAD_CODE", "<error>bad code</error>")
      lambda { @cheddar_getter.plan('BAD_CODE') }.should raise_error(CheddarGetter::Error, 'bad code')
    end
  end
  
  def mock_request(method, request_path, response_xml)
    request_path.gsub!(/^\//, '')
    options = { :body => response_xml, :content_type =>  "text/xml" }
    FakeWeb.register_uri(method, "https://cheddargetter.com/xml/#{request_path}", options)
  end
end
