$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'cheddargetter'
require 'spec'
require 'spec/autorun'
require 'fakeweb'

# Let's keep these specs self-contained.
# All web service requests should be mocked.
FakeWeb.allow_net_connect = false

Spec::Runner.configure do |config|
  
end
