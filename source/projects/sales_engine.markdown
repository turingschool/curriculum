---
layout: page
title: SalesEngine
---

In this project you'll practice building a system of several interacting Ruby objects using TDD.

<div class="note">
<p>This project is open source. If you notice errors, typos, or have questions/suggestions, please <a href="https://github.com/JumpstartLab/curriculum/blob/master/source/projects/sales_engine.markdown">submit them to the project on Github</a>.</p>
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

You will have a repository for each type of object:

* `MerchantRepository.new` holds a collection of `Merchant` instances
* `InvoiceRepository.new` holds a collection of `Invoice` instances
* `ItemRepository.new` holds a collection of `Item` instances
* `InvoiceItemRepository.new` holds a collection of `InvoiceItem` instances
* `CustomerRepository.new` holds a collection of `Customer` instances

The instance of `SalesEngine` will have a reference to each of these repositories, which can be accessed like so:

```ruby
engine = SalesEngine.new
engine.startup

engine.merchant_repository
engine.invoice_repository
engine.item_repository
engine.invoice_item_repository
engine.customer_repository
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

