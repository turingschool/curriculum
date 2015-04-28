---
layout: page
title: SalesEngine
sidebar: true
---

In this project you'll practice building a system of several interacting Ruby objects using TDD.

## Project Overview

### Goals

* Use tests to drive both the design and implementation of code
* Use test fixtures instead of actual data when testing
* Build a complex system of relationships using multiple interacting classes
* Demonstrate the DRY principle with modules and/or duck typing
* Separate parsing and data loading logic from business logic
* Use memoization to improve performance

### Abstract

Let's write a data reporting tool that manipulates and reports on merchant transactional data.

### Getting Started

1. One team member clones the repository at https://github.com/turingschool/sales_engine.
2. `cd sales_engine`
3. `git remote rm origin`
4. Create a new repository on Github, then add that remote to your `sales_engine` from the command line.
5. Push your repository to the new remote origin.
6. Add your teammate(s) as collaborators.
7. Create a [Waffle.io](http://waffle.io) account for project management.
8. Use the [Spec Harness](https://github.com/turingschool/sales_engine_spec_harness) to check your progress along the way. The `README.md` file includes instructions for setup and usage. 

### Data Supplied

We have several files of source data including:

* `customers.csv` - customer names and other attributes
* `transactions.csv` - individual transactions with a marker relating a customer, merchant, invoice, and credit card
* `invoices.csv` - invoices that link transactions to invoice items and hold a status
* `invoice_items.csv` - the item, quantity, and unit price paid for an item in a transaction
* `items.csv` - items available for sale at the merchants
* `merchants.csv` - merchant names and identifying information

Dig into the data files to understand how everything is linked together.
https://github.com/turingschool/sales_engine/tree/master/data

[Sales Engine Diagram](/images/sales_engine.png)

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
* Metaprogramming (`method_missing`, `define_method`, etc)

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

## Base Expectations

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
engine.transaction_repository
```

### Listing and Searching Collections

For each repository class you need to offer:

* `all` returns all instances
* `random` returns a random instance
* `find_by_X(match)`, where `X` is some attribute, returns a single instance whose `X` attribute case-insensitive attribute matches the `match` parameter. For instance, `customer_repository.find_by_first_name("Mary")` could find a `Customer` with the first name attribute `"Mary"` or `"mary"` but not `"Mary Ellen"`.
* `find_all_by_X(match)` works just like `find_by_X` except it returns a collection of _all_ matches. If there is no match, it returns an empty `Array`.

### Relationships

#### `Merchant`

* `items` returns a collection of `Item` instances associated with that merchant for the products they sell
* `invoices` returns a collection of `Invoice` instances associated with that merchant from their known orders

#### `Invoice`

* `transactions` returns a collection of associated `Transaction` instances
* `invoice_items` returns a collection of associated `InvoiceItem` instances
* `items` returns a collection of associated `Items` by way of `InvoiceItem` objects
* `customer` returns an instance of `Customer` associated with this object
* `merchant` returns an instance of `Merchant` associated with this object

#### `InvoiceItem`

* `invoice` returns an instance of `Invoice` associated with this object
* `item` returns an instance of `Item` associated with this object

#### `Item`

* `invoice_items` returns a collection of `InvoiceItems` associated with this object
* `merchant` returns an instance of `Merchant` associated with this object

#### `Transaction`

* `invoice` returns an instance of `Invoice` associated with this object

#### `Customer`

* `invoices` returns a collection of `Invoice` instances associated with this object.

### Business Intelligence

#### `MerchantRepository`

* `most_revenue(x)` returns the top `x` merchant instances ranked by total revenue
* `most_items(x)` returns the top `x` merchant instances ranked by total number of items sold
* `revenue(date)` returns the total revenue for that date across all merchants

#### `Merchant`

* `#revenue` returns the total revenue for that merchant across all transactions
* `#revenue(date)` returns the total revenue for that merchant for a specific invoice date
* `#favorite_customer` returns the `Customer` who has conducted the most successful transactions
* `#customers_with_pending_invoices` returns a collection of `Customer` instances which have pending (unpaid) invoices.  An invoice is considered pending if none of it's transactions are successful.

_NOTE_: Failed charges should never be counted in revenue totals or statistics.

_NOTE_: All revenues should be reported as a `BigDecimal` object with two decimal places.

#### `ItemRepository`

* `most_revenue(x)` returns the top `x` item instances ranked by total revenue generated
* `most_items(x)` returns the top `x` item instances ranked by total number sold

#### `Item`

* `best_day` returns the date with the most sales for the given item using the invoice date

#### `Customer`

* `#transactions` returns an array of `Transaction` instances associated with the customer
* `#favorite_merchant` returns an instance of `Merchant` where the customer has conducted the most successful transactions

#### `Invoice` - Creating New Invoices & Related Objects

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

## Extensions

### Merchant Extension

#### `MerchantRepository`

* `dates_by_revenue` returns an array of Ruby `Date` objects in descending order of revenue
* `dates_by_revenue(x)` returns the top `x` days of revenue in descending order
* `revenue(range_of_dates)` returns the total revenue for all merchants across several dates

#### `Merchant`

* `revenue(range_of_dates)` returns the total revenue for that merchant across several dates

### Invoice Extension

#### `InvoiceRepository`

* `pending` returns an array of `Invoice` instances for which there is no successful transaction
* `average_revenue` returns a `BigDecimal` of the average total for each processed invoice
* `average_revenue(date)` returns a `BigDecimal` of the average total for each processed invoice for a single date
* `average_items` returns a `BigDecimal` of the average item count for each processed invoice
* `average_items(date)` returns a `BigDecimal` of the average item count for each processed invoice for a single date

_NOTE_: All `BigDecimal` objects should use two decimal places. "Processed invoice" refers to an invoice that has at least one successful transaction.

### Customer Extension

#### `CustomerRepository`

* `most_items` returns the `Customer` who has purchased the most items by quantity
* `most_revenue` returns the `Customer` who has generated the most total revenue

#### `Customer`

* `#days_since_activity` returns a count of the days since their last transaction, zero means today.
* `#pending_invoices` returns an array of `Invoice` instances for which there is no successful transaction

## Evaluation Rubric

The project will be assessed with the following rubric:

### 1. Functional Expectations

* 4: Application fulfills all base expectations and two extensions
* 3: Application fulfills all base expectations as tested by the spec harness
* 2: Application has some missing functionality but no crashes
* 1: Application crashes during normal usage

### 2. Test-Driven Development

* 4: Application is broken into components which are well tested in both isolation and integration using appropriate data
* 3: Application is well tested but does not balance isolation and integration tests, using only the data necessary to test the functionality
* 2: Application makes some use of tests, but the coverage is insufficient
* 1: Application does not demonstrate strong use of TDD

### 3. Encapsulation / Breaking Logic into Components

* 4: Application is expertly divided into logical components each with a clear, single responsibility
* 3: Application effectively breaks logical components apart but breaks the principle of SRP
* 2: Application shows some effort to break logic into components, but the divisions are inconsistent or unclear
* 1: Application logic shows poor decomposition with too much logic mashed together

### 4. Fundamental Ruby & Style

* 4:  Application demonstrates excellent knowledge of Ruby syntax, style, and refactoring
* 3:  Application shows strong effort towards organization, content, and refactoring
* 2:  Application runs but the code has long methods, unnecessary or poorly named variables, and needs significant refactoring
* 1:  Application generates syntax error or crashes during execution

### 5. Enumerable & Collections

* 4: Application consistently makes use of the best-choice Enumerable methods
* 3: Application demonstrates comfortable use of appropriate Enumerable methods
* 2: Application demonstrates functional knowledge of Enumerable but only uses the most basic techniques
* 1: Application demonstrates deficiencies with Enumerable and struggles with collections

### 6. Code Sanitation

The output from `rake sanitation:all` shows...

* 4: Zero complaints
* 3: Five or fewer complaints
* 2: Six to ten complaints
* 1: More than ten complaints
