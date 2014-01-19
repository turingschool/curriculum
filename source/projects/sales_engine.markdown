---
layout: page
title: SalesEngine
---

In this project you'll practice building a system of several interacting Ruby objects using TDD.

<div class="note">
<p>This project is open source. If you notice errors, typos, or have questions/suggestions, please <a href="https://github.com/JumpstartLab/curriculum/blob/master/source/projects/sales_engine.markdown">submit them to the project on GitHub</a>.</p>
</div>

### Learning Goals

* Use tests to drive creation of code
* Build a system using multiple interacting classes
* Maintain high test coverage
* Use duck typing to share interactions across similar types
* Use modules to share common code

### Abstract

Let's write a data reporting tool that manipulates and reports on merchant transactional data.

### Getting Started

1. One team member forks the repository at https://github.com/gschool/sales_engine
2. Add the second team member as a collaborator

### Data Supplied

We have several files of source data including:

* `customers.csv` - customer names and other attributes
* `transactions.csv` - individual transactions with a marker relating a customer, merchant, invoice, and credit card
* `invoices.csv` - invoices that link transactions to invoice items and hold a status
* `invoice_items.csv` - the item, quantity, and unit price paid for an item in a transaction
* `items.csv` - items available for sale at the merchants
* `merchants.csv` - merchant names and identifying information

Dig into the data files to understand how everything is linked together.

https://github.com/gSchool/sales_engine/tree/master/data

### Understandings

* The data was created from customer orders where:
  * One invoice connects the customer to multiple invoice items, one or more transactions, and one merchant
  * At least one transaction where their credit card is charged. If the charge fails, more transactions may be created for that single invoice.
  * One or more invoice items: one for each item that they ordered
* The transaction references only the invoice
* The invoice item references an item and an invoice
* The item is connected to many invoice items and one merchant
* The merchant is connected to many invoices and many items
* Prices, as represented in the CSVs, are in cents. Anytime you return a revenue total (like in `Merchant#revenue`) you must return a `BigDecimal` representating dollars and cents (two decimals, rounded to the nearest cent).

### Restrictions

Project implementation may *not* use:

* Databases (sqlite3, PostgreSQL, MySQL, MongoDB, Redis, etc)
* Rails' `ActiveRecord` library or a similar object-relational mappers (including `Sequel`, `DataMapper`, etc)
* Your implementation may not use `Struct` or `OpenStruct`

#### Test Independence

You should have a rake task that runs all the tests, like this:

```bash
rake test
```

In addition, each of your test files must be able to run independently:

```bash
ruby test/merchant_test.rb
ruby test/invoice_item_test.rb
```

### Base Expectations

You are to build several classes implementing an API which allows for querying of this data including the objects and methods listed below.

Before digging too deeply into the listed methods below, you need to build a system which can parse the data files and create relationships between all the various objects.

### Entry Point

After calling the following code is called, all the dependencies should be loaded up:

```ruby
engine = SalesEngine.new
engine.startup
```

The entry point must live in a file named `lib/sales_engine`, and the require statements for the other classes in the project must be `require_relative`:

```ruby
require 'csv'
require_relative 'merchant'
require_relative 'merchant_repository'
# etc

class SalesEngine
  # your code goes here
end
```

You will have a repository for each type of object:

* `MerchantRepository.new` holds a collection of `Merchant` instances
* `InvoiceRepository.new` holds a collection of `Invoice` instances
* `ItemRepository.new` holds a collection of `Item` instances
* `InvoiceItemRepository.new` holds a collection of `InvoiceItem` instances
* `CustomerRepository.new` holds a collection of `Customer` instances
* `TransactionRepository.new` holds a collection of `Transaction` instances

The instance of `SalesEngine` will have a reference to each of these repositories, which can be accessed like so:

```ruby
engine = SalesEngine.new
engine.startup

engine.merchant_repository
engine.invoice_repository
engine.item_repository
engine.invoice_item_repository
engine.customer_repository
engine.transactions_repository
```

#### All entries in a collection

Each repository should provide access to the entire collection via the method `all`:

```ruby
repository = MerchantRepository.new
repository.all # provides access to all the loaded merchants
```

#### Searching

For your Repository classes you need to build:

* `random` returns a random instance
* `find_by_X(match)`, where `X` is some attribute, returns a single instance whose `X` attribute case-insensitive attribute matches the `match` parameter. For instance, `Customer.find_by_first_name("Mary")` could find a `Customer` with the first name attribute `"Mary"` or `"mary"` but not `"Mary Ellen"`.
* `find_all_by_X(match)` works just like `find_by_X` except it returns a collection of _all_ matches. If there is no match, it returns an empty `Array`.

#### Relationships

##### `Merchant`

* `items` returns a collection of `Item` instances associated with that merchant for the products they sell
* `invoices` returns a collection of `Invoice` instances associated with that merchant from their known orders

##### `Invoice`

* `transactions` returns a collection of associated `Transaction` instances
* `invoice_items` returns a collection of associated `InvoiceItem` instances
* `items` returns a collection of associated `Items` by way of `InvoiceItem` objects
* `customer` returns an instance of `Customer` associated with this object
* `merchant` returns an instance of `Merchant` associated with this object

##### `InvoiceItem`

* `invoice` returns an instance of `Invoice` associated with this object
* `item` returns an instance of `Item` associated with this object

##### `Item`

* `invoice_items` returns a collection of `InvoiceItems` associated with this object
* `merchant` returns an instance of `Merchant` associated with this object

##### `Transaction`

* `invoice` returns an instance of `Invoice` associated with this object

##### `Customer`

* `invoices` returns a collection of `Invoice` instances associated with this object.

#### Business Intelligence

##### `MerchantRepository`

* `most_revenue(x)` returns the top `x` merchant instances ranked by total revenue
* `most_items(x)` returns the top `x` merchant instances ranked by total number of items sold
* `revenue(date)` returns the total revenue for that date across all merchants

##### `Merchant`

* `#revenue` returns the total revenue for that merchant across all transactions
* `#revenue(date)` returns the total revenue for that merchant for a specific invoice date
* `#favorite_customer` returns the `Customer` who has conducted the most successful transactions
* `#customers_with_pending_invoices` returns a collection of `Customer` instances which have pending (unpaid) invoices

_NOTE_: Failed charges should never be counted in revenue totals or statistics.

_NOTE_: All revenues should be reported as a `BigDecimal` object with two decimal places.

##### `ItemRepository`

* `most_revenue(x)` returns the top `x` item instances ranked by total revenue generated
* `most_items(x)` returns the top `x` item instances ranked by total number sold

##### `Item`

* `best_day` returns the date with the most sales for the given item using the invoice date

##### `Customer`

* `#transactions` returns an array of `Transaction` instances associated with the customer
* `#favorite_merchant` returns an instance of `Merchant` where the customer has conducted the most successful transactions

##### `Invoice` - Creating New Invoices & Related Objects

Given a hash of inputs, you can create new invoices on the fly using this syntax:

```
invoice = invoice_repository.create(customer: customer, merchant: merchant, status: "shipped",
                         items: [item1, item2, item3])
```

Assuming that `customer`, `merchant`, and `item1`/`item2`/`item3` are instances of their respective classes.

You should determine the quantity bought for each item by how many times the item is in the `:items` array.
So, for `items: [item1, item1, item2]`, the quantity bought will be 2 for `item1` and 1 for `item2`.

Then, on such an invoice you can call:

```ruby
invoice.charge(credit_card_number: "4444333322221111",
               credit_card_expiration: "10/13", result: "success")
```

The objects created through this process would then affect calculations, finds, etc.

### Extensions

#### Merchant Extension

##### `MerchantRepository`

* `dates_by_revenue` returns an array of Ruby `Date` objects in descending order of revenue
* `dates_by_revenue(x)` returns the top `x` days of revenue in descending order
* `revenue(range_of_dates)` returns the total revenue for all merchants across several dates

##### `Merchant`

* `revenue(range_of_dates)` returns the total revenue for that merchant across several dates

#### Invoice Extension

##### `InvoiceRepository`

* `pending` returns an array of `Invoice` instances for which there is no successful transaction
* `average_revenue` returns a `BigDecimal` of the average total for each processed invoice
* `average_revenue(date)` returns a `BigDecimal` of the average total for each processed invoice for a single date
* `average_items` returns a `BigDecimal` of the average item count for each processed invoice
* `average_items(date)` returns a `BigDecimal` of the average item count for each processed invoice for a single date

_NOTE_: All `BigDecimal` objects should use two decimal places. "Processed invoice" refers to an invoice that has at least one successful transaction.

#### Customer Extension

##### `CustomerRepository`

* `most_items` returns the `Customer` who has purchased the most items by quantity
* `most_revenue` returns the `Customer` who has generated the most total revenue

##### `Customer`

* `#days_since_activity` returns a count of the days since their last transaction, zero means today.
* `#pending_invoices` returns an array of `Invoice` instances for which there is no successful transaction

