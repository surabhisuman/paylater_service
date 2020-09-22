class User

  attr_accessor :name, :email, :credit_limit, :current_limit, :transactions

  def initialize(name: ,email: ,credit_limit:, current_limit:, transactions: [])
    params_hash = method(__method__).parameters.map.collect do |_, key|
      [key, binding.local_variable_get(key)]
    end.to_h
    params_hash.each do |key, val|
      instance_variable_set("@#{key}".to_sym, val)
    end
  end
  
  @@all = []

  def update(name: nil, email: nil, credit_limit: nil, current_limit: nil, transactions: nil)
    params_hash = method(__method__).parameters.map.collect do |_, key|
      [key, binding.local_variable_get(key)]
    end.to_h
    params_hash.compact!
    params_hash.each do |key, val|
      instance_variable_set("@#{key}".to_sym, val)
    end
  end
  
  class << self

    def create(name:, email: , credit_limit: )
      unless credit_limit.positive? # TODO: add to a hook
        Readline.readline('Invalid credit limit! Value should be > 0')
        return
      end
      user = User.new(
        name: name,
        email: email,
        credit_limit: credit_limit.to_i,
        current_limit: credit_limit.to_i,
        transactions: []
      )
      @@all << user
      Readline.readline("#{name}(#{credit_limit})")
    end

    def find_by_name(name) # finds by name
      @@all.find do |user|
        user.name == name
      end
    end

    def total_dues
      @@all.select { |user| (user.credit_limit - user.current_limit).positive? }
    end

    def credit_limit_reached
      @@all.select { |user| user.current_limit.zero? }.map(&:name)
    end
  end

end