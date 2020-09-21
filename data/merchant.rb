class Merchant

  attr_accessor :name, :discount_percentage, :due_amount, :discount_amount

  def initialize(name: ,discount_percentage:,due_amount: 0, discount_amount: 0)
    params_hash = method(__method__).parameters.map.collect do |_, key|
      [key, binding.local_variable_get(key)]
    end.to_h
    params_hash.each do |key, val|
      instance_variable_set("@#{key}".to_sym, val)
    end
  end

  def update(name: nil, email: nil, credit_limit: nil)
    params_hash = method(__method__).parameters.map.collect do |_, key|
      [key, binding.local_variable_get(key)]
    end.to_h
    params_hash.compact!
    params_hash.each do |key, val|
      instance_variable_set("@#{key}".to_sym, val)
    end
  end

  @@all = []

  class << self
    def simpl_merchant
      @@simple_merchant ||= Merchant.create("simpl", 0)
    end

    def create(name: ,discount_percentage:)
      merchant = Merchant.new(
        name: name, 
        discount_percentage: discount_percentage,
        total_amount: 0
      )
      @@all << merchant
    end

    def find_by_name(name) # finds by name
      @@all.find do |user|
        user.name == name
      end
    end

    def where(options = {})
      @@all.select do |merchant|
        flag = true
        options.keys.each do |key| 
          flag &= merchant.public_send(key) == options[key]
        end
        flag
      end
    end
  end

end