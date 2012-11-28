---
layout: page
title: Transactions
section: Models
---

As your business logic gets complex you may need to implement transactions. The classic example is a bank funds transfer from account A to account B. If the withdrawal from account A fails then the deposit to account B should either never take place or be rolled back.

## Basics

All the complexity is handled by `ActiveRecord::Transactions`. Any model class or instance has a method named `.transaction`. When called and passed a block, that block will be executed inside a database transaction. If there's an exception raised, the transaction will automatically be rolled back.

### Example

Let's work with the account transfer scenario. It could be implemented like this:

```ruby
@account_a = Account.find_by_name("A")
@account_b = Account.find_by_name("B")
Account.transaction do
  @account_a.balance -= transfer_amount
  @account_a.save!
  @account_b.balance += transfer_amount
  @account_b.save!
end
```

First we fetch the account objects then start a transaction with `Account.transaction`. It actually makes *no difference* which `ActiveRecord` class or instance we call this method on. We could also have used any of these:

* `@account_a.transaction do`
* `@account_b.transaction do`
* `ActiveRecord::Base.transaction do`
* `self.transaction do`
* `self.class.transaction do`

The choice would make absolutely no difference in the execution. 

Rails will open a transaction in the database engine, then start executing the block. There are three possibilities:

1. If no exceptions occur during the block then Rails closes the transaction and the database commits the data
2. If there is an exception, Rails will tell the database to cancel the transaction and no data is changed
3. If the entire Rails process or server dies then the transaction will timeout and be cancelled by the database

The critical step to notice is the use of `.save!` instead of `.save`. The former will raise an exception when the operation fails, while the latter will just return `false`. If we just used `.save` our transaction would *never fail*. If you wanted to use `.save`, here's one possible refactoring:

```ruby
Account.transaction do
  @account_a.balance -= transfer_amount
  @account_b.balance += transfer_amount
  raise "Transaction Failed" unless @account_a.save && @account_b.save
end
```

It's ideal to run as few instructions as possible inside the transaction because keeping the connection open is taxing on the database. You could pull the two math operation out to save a few microseconds. Here's a final version:

```ruby
@account_a = Account.find_by_name("A")
@account_b = Account.find_by_name("B")
@account_a.balance -= transfer_amount
@account_b.balance += transfer_amount
Account.transaction do
  raise "Transaction Failed" unless @account_a.save && @account_b.save
end
```

## Callbacks

There are two additional callbacks available when working with transactions.

### `after_commit`

This callback fires when the transaction succeeds.

### `after_rollback`

This callback fires when the transaction fails.

## Sample Implementation

Here's a sample model using a transaction and both callbacks:

```ruby
class Account < ActiveRecord::Base
  after_commit :transaction_success
  after_rollback :transaction_failed

  def transfer_funds_to(amount, target)
    self.balance -= amount
    target.balance += amount
    Account.transaction do
      raise "Transaction Failed" unless self.save && target.save
    end
  end
  
private
  def transaction_success
    Logger.info "Transfer succeed for Account #{self.to_param}"
  end
  
  def transaction_failed
    Logger.warn "Transfer failed for Account #{self.to_param}"
  end  
end
```

## References

* Rails API for `ActiveRecord::Transactions`: http://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html
