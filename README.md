# paylater_service
User - name, email, credit_limit, current_limit, -> has many transactions
Merchant - name, discount percentage, due_amount, discount_amount -> has many transactions
Transaction -> amount, type belongs_to :user, belongs_to :merchant

Simpl as a merchant - for payback transactions

Functions:
1. User - update[instance method] (for updating any info e.g. credit limit), create total dues, credit_limit_reached, find_by_name [class methods]
2. merchant - update[instance method], Simpl merchant, create, find[class method]
3. transaction - 
before create - check for credit limit, type of merchant, type of txn - debit or payback
after create - [update user(current due and transactions), update merchant(due amount and discount_amount)]

There are various use cases this service is intended to fulfil -
● allow merchants to be onboarded with the amount of discounts they offer
● allow merchants to change the discount they offer
● allow users to be onboarded (name, email-id and credit-limit)
● allow a user to carry out a transaction of some amount with a merchant.
● allow a user to pay back their dues (full or partial)
● Reporting:
○ how much discount we received from a merchant till date
○ dues for a user so far
○ which users have reached their credit limit
○ total dues from all users together

new user u1 u1@email.in 1000 # name, email, credit-limit
new merchant m1 2% # name, discount-percentage
new txn u1 m1 400 # user, merchant, txn-amount
update merchant m1 1% # merchant, new-discount-rate
payback u1 300 # user, payback-amount
report discount m1
report dues u1
report users-at-credit-limit
report total-dues
