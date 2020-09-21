class Transaction

  attr_accessor :name, :discount_percentage

  # enum transaction_type = ['debit', 'payback']

  def initialize(user_name: , merchant_name: nil, amount: , type: 'debit')
    params_hash = method(__method__).parameters.map.collect do |_, key|
      [key, binding.local_variable_get(key)]
    end.to_h
    params_hash.each do |key, val|
      instance_variable_set("@#{key}".to_sym, val)
    end
  end

  def self.create(user_name: , merchant_name: nil, amount: , type: 'debit')
    unless allowed_credit_limit(amount, type) # TODO: add to a hook
      Readline.readline('Invalid transaction! Allowed credit limit is', user.credit_limit)
      return
    end
    transaction = Transaction.new(
      type: type,
      merchant_name: get_merchant(type, merchant_name),
      user_name: user_name,
      amount: amount
    )
    @@all << transaction
    update_user
    update_merchant
  end

  @@all = []

  private

  def get_merchant(type, merchant_name)
    type == 'payback' ? Merchant.simpl_merchant.name : merchant_name
  end

  def update_user
    current_limit = user.credit_limit
    txn_amount = type == 'payback' ? amount : -amount
    updated_limit = current_limit + txn_amount
    transactions = user.transactions + [self]
    user.update(current_limit: updated_limit, transactions: transactions)
  end

  def update_merchant
    return if type == 'payback'

    merchant = Merchant.find_by_name(merchant_name)
    merchant_due_amount = merchant.total_amount + (amount - discount_amount)
    merchant_discount_amount = merchant.discount_amount + discount
    merchant.update(due_amount: merchant_due_amount, discount_amount: merchant_discount_amount) 
  end

  def discount(amount, merchant)
    (amount * merchant.discount_percentage.to_f)/100
  end

  def user
    @user ||= User.find_by_name(user_name)
  end

  def allowed_credit_limit(amount, type)
    if type == 'debit'
      return false if amount.to_i > user.current_limit.to_i
    else
      return false  if amount.to_i > (user.credit_limit - user.current_limit).to_i
    end
  end

end