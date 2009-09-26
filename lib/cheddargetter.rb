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
  
  private
  
  def get(path)
    path = "https://cheddargetter.com/xml" + path
    response = self.class.get(path)
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
