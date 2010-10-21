require 'rubygems'
require 'httparty'

class CheddarGetter
  include HTTParty
  
  class Error < StandardError; end
  
  def initialize(username, password, product_code)
    @product_code = product_code
    self.class.basic_auth(username, password)
  end
  
  # Returns an array of all plans:
  #
  #   [{"name" => "Little", "code" => "LITTLE", "recurringChargeAmount" => "1.00", etc...},
  #    {"name" => "Big",    "code" => "BIG",    "recurringChargeAmount" => "100.00", etc..}]
  def plans
    response = get("/plans/get/productCode/#{@product_code}")
    normalize_collection(response, 'plans', 'plan')
  end
  
  # Returns the requested plan as a hash:
  #
  #   {"name" => "Little", "code" => "LITTLE", "recurringChargeAmount" => "1.00", etc...}
  def plan(plan_code)
    response = get("/plans/get/productCode/#{@product_code}/code/#{plan_code}")
    normalize(response, 'plans', 'plan')
  end
  
  def customers
    response = get("/customers/get/productCode/#{@product_code}")
    normalize_collection(response, 'customers', 'customer')
  rescue Error => e # HACK! the api is inconsitent about returning empty nodes vs. sending errors
    if e.message =~ /no customers found/i
      return []
    else
      raise
    end
  end

  def customer(customer_code)
    response = get("/customers/get/productCode/#{@product_code}/code/#{customer_code}")
    normalize(response, 'customers', 'customer')
  end
  
  # Pass an attributes hash for the new customer:
  # 
  #   :code       => 'CUSTOMER-1',            # required
  #   :firstName  => 'Justin',                # required
  #   :lastName   => 'Blake',                 # required
  #   :email      => 'justin@adsdevshop.com', # required
  #   :company    => 'ADS',                   # optional
  #   :subscription => {
  #     :planCode     => "INDY",          # required
  #     :ccFirstName  => "Justin",        # required unless plan is free
  #     :ccLastName   => "Blake",         # required unless plan is free
  #     :ccNumber     => "numbers only",  # required unless plan is free
  #     :ccExpiration => "MM-YYYY",       # required unless plan is free
  #     :ccZip        => "5 digits only"  # required unless plan is free
  #   }
  #
  # The full request dictionary can be found here:
  # https://cheddargetter.com/developers#add-customer
  #
  # Returns the customer:
  #
  #   {"firstName" => "Justin", "lastName" => "Blake", etc...}
  def create_customer(attributes)
    response = post("/customers/new/productCode/#{@product_code}", :body => attributes)
    normalize(response, 'customers', 'customer')
  end
  
  # Attributes are the same as #create_customer
  # Only included attributes will be udpated.
  # Credit Card information is only required if the plan is not free and
  # no credit card information is already saved.
  def update_customer(customer_code, attributes)
    # Limit potential damage but calling edit-customer if we're
    # not changing any subscription information.
    response = if attributes[:subscription]
                 post("/customers/edit/productCode/#{@product_code}/code/#{customer_code}", :body => attributes)
               else
                 post("/customers/edit-customer/productCode/#{@product_code}/code/#{customer_code}", :body => attributes)
               end
    normalize(response, 'customers', 'customer')
  end

  # Returns an empty array.
  def delete_customer(customer_code)
    response = post("/customers/delete/productCode/#{@product_code}/code/#{customer_code}")
    normalize(response, 'customers', 'customer')
  end
  
  # Returns the customer:
  #
  #   {"firstName" => "Justin", "lastName" => "Blake", etc...}
  def cancel_subscription(customer_code)
    response = post("/customers/cancel/productCode/#{@product_code}/code/#{customer_code}")
    normalize(response, 'customers', 'customer')
  end
  
  # Pass an attributes hash for the updated subscription:
  # 
  #   :planCode     => "INDY",          # optional
  #   :ccFirstName  => "Justin",        # required unless plan is free or already has credit card
  #   :ccLastName   => "Blake",         # required unless plan is free or already has credit card
  #   :ccNumber     => "numbers only",  # required unless plan is free or already has credit card
  #   :ccExpiration => "MM-YYYY",       # required unless plan is free or already has credit card
  #   :ccZip        => "5 digits only"  # required unless plan is free or already has credit card
  #
  # Returns the customer:
  #
  #   {"firstName" => "Justin", "lastName" => "Blake", etc...}
  def update_subscription(customer_code, attributes)
    response = post("/customers/edit-subscription/productCode/#{@product_code}/code/#{customer_code}", :body => attributes)
    normalize(response, 'customers', 'customer')
  end
  
  private
  
  def get(path)
    request(:get, path)
  end
  
  def post(path, options = {})
    request(:post, path, options)
  end

  def request(method, path, options = {})
    path = "https://cheddargetter.com/xml" + path
    response = self.class.send(method, path, options)
    raise Error.new(response['error']) if response['error']
    response
  end
  
  def normalize(response, parent_node, child_node)
    return [] unless response[parent_node]
    response[parent_node][child_node]
  end
  
  def normalize_collection(response, parent_node, child_node)
    children = normalize(response, parent_node, child_node)
    children = [children] unless children.is_a?(Array)
    children
  end
end
