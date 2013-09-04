---
layout: page
title: SalesEngineWeb
sidebar: true
---

Did you enjoy [SalesEngine]({% page_url projects/sales_engine %})? Are you a much better programmer now than you were three weeks ago? Let's find out!

## Overview

Let's rebuild SalesEngine using:

* Sequel as a database backend
* Sinatra as a front-end
* JSON as our output format
* Acceptance, Integration, and Unit Testing
* Strong mocking and stubbing where appropriate

### Data Supplied

We'll use the same CSV data files but will upload them through a web interface to the app.

### Delivery

Your project will be evaluated as it runs on Heroku.

## Base Expectations

### Searching

For your merchants, invoices, items, invoice items, and customers you need to build the search functionality defined below. `/merchants/` has been used as an example, but assume it applies to `/invoices/`, `/items/`, etc.

#### Random

`/merchants/random` returns a random merchant.

#### Single Finders

Each data category should offer `find` finders to return a single object representation like this:

```
/merchants/find?id='12'
```

Which would find the one merchant with ID `12`. The finder should work with any of the attributes defined on the data type and always be case insensitive.

#### Multi-Finders

Each category should offer `find_all` finders like this:

```
/merchants/find_all?name='My%20Shop'
```

Which would find all the merchants whose name includes the substring "my shop", case insensitive. The finder should work with any of the attributes defined on the data type and always be case insensitive.

### Relationships

Relationships in the system will be represented by nested URLs.

#### Merchants

* `/merchants/:id/items` returns a collection of items associated with that merchant for
* `/merchants/:id/invoices` returns a collection of invoices associated with that merchant from their known orders

#### Invoices

* `/invoices/:id/transactions` returns a collection of associated transactions
* `/invoices/:id/invoice_items` returns a collection of associated invoice items
* `/invoices/:id/items` returns a collection of associated items
* `/invoices/:id/customer` returns the associated customer
* `/invoices/:id/merchant` returns the associated merchant

#### Invoice Items

* `/invoice_items/:id/invoice` returns the associated invoice
* `/invoice_items/:id/item` returns the associated item

#### Items

* `/items/:id/invoice_items` returns a collection of associated invoice items
* `/items/:id/merchant` returns the associated merchant

#### Transactions

* `/transactions/:id/invoice` returns the associated invoice

#### Customers

* `/customers/:id/invoices` returns a collection of associated invoices
* `/customers/:id/transactions` returns a collection of associated transactions

### Business Intelligence

#### Merchants

##### All Merchants

* `/merchants/most_revenue?quantity=x` returns the top `x` merchants ranked by total revenue
* `/merchants/most_items?quantity=x` returns the top `x` merchants ranked by total number of items sold
* `/merchants/revenue?date=x` returns the total revenue for date `x` across all merchants

##### A Single Merchant

* `/merchants/:id/revenue` returns the total revenue for that merchant across all transactions
* `/merchants/:id/revenue?date=x` returns the total revenue for that merchant for a specific invoice date `x`
* `/merchants/:id/favorite_customer` returns the customer who has conducted the most successful transactions
* `/merchants/:id/customers_with_pending_invoices` returns a collection of customers which have pending (unpaid) invoices

_NOTE_: Failed charges should never be counted in revenue totals or statistics.

_NOTE_: All revenues should be reported as a float with two decimal places.

#### Items

* `/items/most_revenue?quantity=x` returns the top `x` items ranked by total revenue generated
* `/items/most_items?quantity=x` returns the top `x` item instances ranked by total number sold
* `/items/:id/best_day` returns the date with the most sales for the given item using the invoice date

#### Customers

* `/customers/:id/favorite_merchant` returns a merchant where the customer has conducted the most successful transactions

## Evaluation Criteria

This project will be peer assessed using automated tests and the criteria below.

1. Correctness
2. Testing
3. Style
4. Effort