require 'pry'

Dir[File.dirname(__FILE__) + '/data/**/*.rb'].each do |filename|
  require filename
end

SUPPORTED_ACTIONS = ['new', 'update', 'payback', 'report']

def pre_process_input(input)
  @actionable_items = input.split(/\s/)
  @action = @actionable_items[0]
  validate_action
end

def process
  case @action
  when 'new'
    create_actions
  when 'payback'
    args = @actionable_items[1..-1]
    Data::Transaction.create(user_name: args[0], amount: args[1].to_i, type: 'payback')
  when 'update'
    update_actions
  when 'report'
    report_actions
  end
end

def report_actions
  actionable = @actionable_items[1]
  case actionable
  when 'discount'
    merchant = Data::Merchant.find_by_name(@actionable_items[2])
    Readline.readline(merchant.discount_amount.to_s)
  when 'dues'
    user = Data::User.find_by_name(@actionable_items[2])
    Readline.readline((user.credit_limit - user.current_limit).to_s)
  when 'users-at-credit-limit'
    Readline.readline("#{Data::User.credit_limit_reached}")
  when 'total-dues'
    dues = Data::User.total_dues
    dues.each do |due_user|
      Readline.readline("#{due_user.name}: #{due_user.credit_limit - due_user.current_limit}")
    end
  else
    Readline.readline('Action not defined')
  end
end

def update_actions
  klass = @actionable_items[1]
  args = @actionable_items[2..-1]
  name, modified_klass, update_params = 
    if klass == 'merchant'
      merchant_update_params(args)
    elsif klass == 'user'
      user_update_params(args)
    end
  data_object = Kernel.const_get(modified_klass).send(:find_by_name, name)
  data_object.update(update_params)
end

def create_actions
  klass = @actionable_items[1]
  args = @actionable_items[2..-1]
  modified_klass, create_params =
    if klass == 'user'
      user_create_params(args)
    elsif klass == 'merchant'
      merchant_create_params(args)
    elsif klass == 'txn'
      txn_create_params(args)
    else
      abort('Invalid action')
    end
  Kernel.const_get(modified_klass).send(:create, create_params)
end

def validate_action
  abort('Aborting! Invalid action') unless SUPPORTED_ACTIONS.include?@action
end

def user_create_params(args)
  name = args[0]
  email = args[1]
  credit_limit = args[2].to_i
  create_params = {name: name, email: email, credit_limit: credit_limit}
  ['User', create_params]
end

def merchant_create_params(args)
  name = args[0]
  discount_percentage = args[1]
  create_params = { name: name, discount_percentage: discount_percentage }
  ['Merchant', create_params]
end

def txn_create_params(args)
  user_name = args[0]
  merchant_name = args[1]
  amount = args[2].to_i
  create_params = {user_name: user_name, merchant_name: merchant_name, amount: amount, type: 'debit'}
  ['Transaction', create_params]
end

def merchant_update_params(args)
  merchant_name = args[0]
  discount_percentage = args[1]
  update_params = {name: merchant_name, discount_percentage: discount_percentage}
  [merchant_name, 'Merchant', update_params]
end

def user_update_params(args)
  user_name = args[0]
  credit_limit = args[1].to_i
  update_params = {name: user_name, credit_limit: credit_limit}
  [user_name, 'User', update_params]
end

while true
  input = Readline.readline(' >>', true)
  pre_process_input(input)
  process
end