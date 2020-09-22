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

  def update(name: nil, discount_percentage: nil, due_amount: nil, discount_amount: nil)
    params_hash = method(__method__).parameters.map.collect do |_, key|
      [key, binding.local_variable_get(key)]
    end.to_h
    params_hash.compact!
    params_hash.each do |key, val|
      instance_variable_set("@#{key}".to_sym, val)
    end
    Readline.readline("#{name}(#{discount_percentage})") if params_hash[:discount_percentage]
  end

  def update_dues(transaction)
    return if name == 'simpl' || transaction.type == 'payback'

    discount = (transaction.amount * discount_percentage.split('%').first.to_f)/100
    merchant_due_amount = due_amount + (transaction.amount - discount)
    merchant_discount_amount = discount_amount + discount
    update(due_amount: merchant_due_amount, discount_amount: merchant_discount_amount) 
  end

  @@all = []

  class << self
    def simpl_merchant
      @@simpl_merchant ||= Merchant.create(name: 'simpl', discount_percentage: 0)
    end

    def create(name: ,discount_percentage:)
      merchant = Merchant.new(
        name: name, 
        discount_percentage: discount_percentage,
        due_amount: 0,
        discount_amount: 0
      )
      @@all << merchant
      Readline.readline("#{name}(#{discount_percentage})") unless name == 'simpl'
      merchant
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