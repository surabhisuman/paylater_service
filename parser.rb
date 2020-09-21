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
    klass.constanize.send(:create, args.to_h)
  when 'payback'
  when 'new', 'update'
    klass = actionable_items[1]
    args = actionable_items[2..-1]
    klass.constanize.send(@action, args)
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