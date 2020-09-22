require 'pry'
Dir[File.dirname(__FILE__) + '/data/**/*.rb'].each do |filename|
  require filename
end
SUPPORTED_ACTIONS = ['new', 'update', 'payback', 'report']

def pre_process_input(input)
  actionable_items = input.split(/\s/)
  @action = actionable_items[0]
  validate_action
  process(actionable_items)
end

def validate_action
  abort("Aborting! Invalid action") unless SUPPORTED_ACTIONS.include?@action
end

def process(actionable_items)
  case @action
  when 'new'
    klass = actionable_items[1]
    args = actionable_items[2..-1]
    if klass == 'user'
      name = args[0]
      email = args[1]
      credit_limit = args[2]
      Data::User.create(name: name, email: email, credit_limit: credit_limit.to_i)
    elsif klass == 'merchant'
      name = args[0]
      discount_percentage = args[1]
      Data::Merchant.create(name: name, discount_percentage: discount_percentage)
    elsif klass == 'txn'
      user_name = args[0]
      merchant_name = args[1]
      amount = args[2]
      Data::Transaction.create(user_name: user_name,merchant_name: merchant_name, amount: amount, type: 'debit')
    else
      Readline.readline('Invalid action')
    end
  when 'payback'
    args = actionable_items[1..-1]
    Data::Transaction.create(user_name: args[0], amount: args[1].to_i, type: 'payback')
  when 'update'
    klass = actionable_items[1]
    args = actionable_items[2..-1]
    if klass == 'merchant'
      merchant_name = args[0]
      discount_percentage = args[1]
      merchant = Data::Merchant.find_by_name(merchant_name)
      merchant.update(discount_percentage: discount_percentage)
      Readline.readline("#{merchant.name}(#{merchant.discount_percentage})")
    elsif klass == 'user'
      user_name = args[0]
      credit_limit = args[1]
      user = Data::User.find_by_name(user_name)
      user.update(credit_limit: credit_limit.to_i)
      Readline.readline("#{name}(#{credit_limit})")
    end
  when 'report'
    actionable = actionable_items[1]
    case actionable
    when 'discount'
      merchant = Data::Merchant.find_by_name(actionable_items[2])
      Readline.readline("#{merchant.discount_amount}")
    when 'dues'
      user = Data::User.find_by_name(actionable_items[2])
      Readline.readline("#{user.credit_limit - user.current_limit}")
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
end

# def supported_functions
#   case @action
#   when 'new'
#     ['user', 'merchant', 'txn']
#   when 'update'
#     ['merchant']
#   when 'payback'
#     []
#   when 'report'
#     ['discount', 'dues', 'users-at-credit-limit', 'total-dues']
#   else
#     []
#   end
# end
while(true)
  input = Readline.readline(" >>", true)
  pre_process_input(input)
end