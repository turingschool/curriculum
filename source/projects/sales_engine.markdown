---
layout: page
title: SalesEngine
---

In this project you'll practice building a system of several interacting Ruby objects using TDD.

<div class="note">
<p>As this project is very complex, consider the requirements fluid until 11:59PM, Monday, March 26th. Changes will only be made in the case of errors, glaring omissions, or clarifying existing expectations.</p>
</div>

### Learning Goals

* Build a system using multiple interacting classes
* Use duck typing to share interactions across similar types
* Use modules to share common code
* Maintain high test coverage
* Use tests to drive creation of code

### Abstract

Let's write a data reporting tool that manipulates and reports on merchant transactional data.

### Data Supplied

We have several files of source data including:

* `customers.csv` - customer names and other attributes
* `transactions.csv` - individual transactions with a marker relating a customer, merchant, invoice, and credit card
* `invoices.csv` - invoices that link transactions to invoice items and hold a status
* `invoice_items.csv` - the item, quantity, and unit price paid for an item in a transaction
* `items.csv` - items available for sale at the merchants
* `merchants.csv` - merchant names and identifying information

Dig into the data files themselves to understand how everything is linked together.

### Understandings

* When a customer submits an order, the following data is created:
  * One invoice connecting the customer to multiple invoice items, one or more transactions, and one merchant
  * At least one transaction where their credit card is charged. If the charge fails, more transactions may be created for that single invoice.
  * One or more invoice items: one for each item that they ordered
* The transaction references only the invoice
* The invoice item references an item and an invoice
* The item is connected to many invoice items and one merchant
* The merchant is connected to many invoices and many items

### Restrictions

Project implementation may *not* use Rails' `ActiveRecord` library or a similar object-relational mapper (`Sequel`, `DataMapper`, etc). Anything else is fair game.

### Base Expectations

You are to build several classes implementing an API which allows for querying of this data including the objects and methods listed below. Note that `.` signifies a class method and `#` signifies an instance method.

Before digging too deeply into the listed methods below, you need to build a system which can parse the data files and create relationships between all the various objects. 

#### Relationship

##### `Merchant`

* `#items` returns a collection of `Item` instances associated with that merchant for the products they sell
* `#invoices` returns a collection of `Invoice` instances associated with that merchant from their known orders

##### `Invoice`

* `#transactions` returns a collection of associated `Transaction` instances 
* `#invoice_items` returns a collection of associated `InvoiceItem` instances
* `#items` returns a collection of associated `Items` by way of `InvoiceItem` objects
* `#customer` returns an instance of `Customer` associated with this object

##### `InvoiceItem`

* `#invoice` returns an instance of `Invoice` associated with this object
* `#item` returns an instance of `Item` associated with this object

##### `Item`

* `#invoice_items` returns an instance of `InvoiceItems` associated with this object
* `#merchant` returns an instance of `Merchant` associated with this object

##### `Transaction`

* `#invoice` returns an instance of `Invoice` associated with this object

##### `Customer`

* `#invoices` returns a collection of `Invoice` instances associated with this object.

#### Business Intelligence

##### `Merchant`

* `.most_revenue(x)` returns the top `x` merchant instances ranked by total revenue
* `.most_items(x)` returns the top `x` merchant instances ranked by total number of items sold
* `.revenue(date)` returns the total revenue for that date across all merchants
* `#revenue` returns the total revenue for that merchant across all transactions
* `#revenue(date)` returns the total revenue that merchant for a specific date
* `#favorite_customer` returns the `Customer` who has conducted the most transactions

_NOTE_: Failed charges should never be counted in revenue totals or statistics.

_NOTE_: All revenues should be reported as a `BigDemical` object with two decimal places.

##### `Item`

* `.most_revenue(x)` returns the top `x` item instances ranked by total revenue generated
* `.most_items(x)` returns the top `x` item instances ranked by total number sold
* `#best_day` returns the date with the most sales for the given item

##### `Customer`

* `#transactions` returns an array of `Transaction` instances associated with the customer
* `#favorite_merchant` returns an instance of `Merchant` where the customer has conducted the most transactions

### Extensions

##### `Merchant`

Add these four methods to `Merchant`, qualifying as one extension:

* `.dates_by_revenue` returns an array of Ruby `Date` objects in descending order of revenue
* `.dates_by_revenue(x)` returns the top `x` days of revenue in descending order
* `.revenue(range_of_dates)` returns the total revenue for all merchants across several dates
* `#revenue(range_of_dates)` returns the total revenue for that merchant across several dates

##### `Invoice`

Add these five methods to `Invoice`, qualifying as one extension:

* `.pending` returns an array of `Invoice` instances for which there is no successful transaction
* `.average_revenue` returns a `BigDecimal` of the average total for each processed invoice
* `.average_revenue(date)` returns a `BigDecimal` of the average total for each processed invoice for a single date
* `.average_items` returns a `BigDecimal` of the average item count for each processed invoice
* `.average_items(date)` returns a `BigDecimal` of the average item count for each processed invoice for a single date

_NOTE_: All `BigDecimal` objects should use two decimal places.

##### `Customer`

Add these four methods to `Customer`, qualifying as one extension:

* `#days_since_activity` returns a count of the days since their last transaction, zero means today.
* `#pending_invoices` returns an array of `Invoice` instances for which there is no successful transaction
* `.most_items` returns the `Customer` who has purchased the most items by quantity
* `.most_revenue` returns the `Customer` who has generated the most total revenue

##### Pending

As we begin work on the project, we'll cook up one more challenging extension.

### Evaluation Criteria

This project will be peer assessed using automated tests and the rubric below. Automated tests will be available no later than 11:59PM, Monday, March 26th.

1. Correctness
  * 4: All provided tests pass without an error or crash
  * 3: One test failed or crashed
  * 2: Two or three tests failed or crashed
  * 1: More than three tests failed or crashed
  * 0: Program will not run
2. Testing
  * 4: Testing suite covers >95% of application code
  * 3: Testing suite covers 90-94% of application code
  * 2: Testing suite covers 80-89% of application code
  * 1: Testing suite covers 50-89% of application code
  * 0: Testing suite covers <50% of application code
2. Style
  * 4: Source code consistently uses strong code style including lines under 80 characters, methods under 10 lines of code, correct indentation, etc.
  * 3: Source code uses good code style, but breaks the above criteria in two or fewer spots
  * 2: Source code uses mixed style, with two to five style breaks
  * 1: Source code is generally messy with five to ten issues
  * 0: Source code is unacceptable, containing more than style issues
3. Effort
  * 5: Program fulfills all Base Expectations and four Extensions
  * 4: Program fulfills all Base Expectations and two Extensions
  * 3: Program fulfills all Base Expectations
  * 2: Program fulfills Base Expectations except for one or two features.
  * 1: Program fulfills many Base Expectations, but more than two features.
  * 0: Program does not fulfill any of the Base Expectations

### Resources

Data files forthcoming.
