class Transaction

  attr_accessor :user_name, :merchant_name, :amount, :type

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
    unless allowed_credit_limit(amount, type, user_name) # TODO: add to a hook
      Readline.readline('rejected! (reason: credit limit)')
      return
    end
    transaction = Transaction.new(
      type: type,
      merchant_name: get_merchant(type, merchant_name),
      user_name: user_name,
      amount: amount.to_i
    )
    @@all << transaction
    update_user(transaction)
    update_merchant(transaction)
    Readline.readline(message(transaction.type))
  end

  @@all = []

  class << self
    private

    def message(type)
      if type == 'payback'
        "#{@user.name}(dues: #{@user.credit_limit - @user.current_limit})"
      else
        'success!'
      end
    end

    def get_merchant(type, merchant_name)
      type == 'payback' ? Merchant.simpl_merchant.name : merchant_name
    end

    def update_user(transaction)
      current_limit = @user.current_limit
      txn_amount = transaction.type == 'payback' ? transaction.amount : -transaction.amount
      updated_limit = current_limit + txn_amount
      transactions = @user.transactions + [transaction]
      @user.update(current_limit: updated_limit, transactions: transactions)
    end

    def update_merchant(transaction)
      return if transaction.type == 'payback'

      merchant = Merchant.find_by_name(transaction.merchant_name)
      merchant_due_amount = merchant.due_amount + (transaction.amount - discount(merchant, transaction.amount))
      merchant_discount_amount = merchant.discount_amount + discount(merchant, transaction.amount)
      merchant.update(due_amount: merchant_due_amount, discount_amount: merchant_discount_amount) 
    end

    def discount(merchant, amount)
      discount_percentage = merchant.discount_percentage.split('%').first
      (amount * discount_percentage.to_f)/100
    end

    def user(user_name)
      @user ||= User.find_by_name(user_name)
    end

    def allowed_credit_limit(amount, type, user_name)
      if type == 'debit'
        (amount.to_i <= user(user_name).current_limit.to_i)
      else
        (amount.to_i <= (@user.credit_limit - @user.current_limit).to_i)
      end
    end
  end

end