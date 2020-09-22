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

  @@all = []

  class << self

    def create(user_name: , merchant_name: nil, amount: , type: 'debit')
      unless user(user_name).allowed_credit_limit(amount, type) # TODO: add to a hook
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
      @user.update_limit(transaction)
      merchant(transaction.merchant_name).update_dues(transaction)
      Readline.readline(message(transaction.type))
    end

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

    def user(user_name)
      @user = User.find_by_name(user_name)
    end

    def merchant(merchant_name)
      @merchant = Merchant.find_by_name(merchant_name)
    end

  end

end