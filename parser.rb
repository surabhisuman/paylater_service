require 'pry'

SUPPORTED_ACTIONS = ['new', 'update', 'payback', 'report']

input = Readline.readline(">", true).to_i
pre_process_input(input)

def pre_process_input(input)
  actionable_items = input.split(/\s/)
  @action = actionable_items[0]
  validate_action
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
      User.create(name: name, email: email, credit_limit: credit_limit)
    elsif klass == 'merchant'
      name = args[0]
      discount_percentage = args[1]
      Merchant.create(name: name, discount_percentage: discount_percentage)
    else
      Readline.readline('Invalid action')
    end
  when 'payback'
    args = actionable_items[1..-1]
    Transaction.create(user_name: args[0], amount: args[1])
  when 'update'
    klass = actionable_items[1]
    args = actionable_items[2..-1]
    if klass == 'merchant'
      merchant_name = args[0]
      discount_percentage = args[1]
      merchant = Merchant.find_by_name(merchant_name)
      merchant.update(discount_percentage: discount_percentage)
    elsif klass == 'user'
      user_name = args[0]
      credit_limit = args[1]
      user = User.find_by_name(user_name)
      user.update(credit_limit: credit_limit)
    end
  when 'report'
    actionable = actionable_items[1]
    case actionable
    when 'discount'
      merchant = Merchant.find_by_name(actionable_items[2])
      Readline.readline(merchant.discount_amount)
    when 'dues'
      user = User.find_by_name(actionable_items[2])
      Readline.readline(user.credit_limit - user.current_limit)
    when 'users-at-credit-limit'
      User.credit_limit_reached
    when 'total-dues'
      dues = User.total_dues
      dues.each do |due|
        Readline.readline(user.name, ': ', user.credit_limit - user.current_limit)
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